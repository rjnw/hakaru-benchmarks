#lang racket

(require sham
         hakrit
         ffi/unsafe racket/cmdline
        racket/runtime-path)
(define-runtime-path CT.hkr "../../testcode/hkrkt/ClinicalTrial.hkr")
(define module-env (debug-file CT.hkr))
(define n (command-line #:args (n) (string->number n)))
(define-runtime-path xfile "../../input/clinicalTrial/")
(define xdata (file->lines (build-path xfile (number->string n))))

(define hkrsrc "../../testcode/hkrkt/~a.hkr")
(define testname "ClinicalTrial")
(define inputdir "../../input/")

(define (run-test n)
  (define srcfile (format hkrsrc testname))
  (define xfile (format (string-append inputdir testname "/~a") n))

  (define module-env (compile-file srcfile))

  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)

  (define prog (jit-get-function 'prog module-env))

  (define make-array-real (jit-get-function 'make$array<real> module-env))
  (define get-index-array-real (jit-get-function 'get-index$array<real> module-env))
  (define make-array-prob (jit-get-function 'make$array<prob> module-env))
  (define get-index-array-prob (jit-get-function 'get-index$array<prob> module-env))
  (define make-array-nat (jit-get-function 'make$array<nat> module-env))
  (define get-index-array-nat (jit-get-function 'get-index$array<nat> module-env))

  (define make-pair-array-bool (jit-get-function 'make$pair<array<bool>*.array<bool>*> module-env))
  (define make-array-bool (jit-get-function 'make$array<bool> module-env))

  (define treal (jit-get-racket-type 'real module-env))
  (define tprob (jit-get-racket-type 'prob module-env))
  (define tnat (jit-get-racket-type 'nat module-env))
  (define tbool (jit-get-racket-type 'bool module-env))

  (define (make-array f lst type)
    (f  (length lst) (list->cblock lst type)))

  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

  (define (tobool str)
    (match str
      ["True" 1]
      ["False" 0]))

  (define (run-single str)
    (define m1 (regexp-match "\\(\\[(.*)\\],\\[(.*)\\]\\),(.*)\\)" str))
    (when (< (length m1) 4)
      (error "matching line from input"))
    (define a (map tobool (regexp-split "," (second m1))))
    (define b (map tobool (regexp-split "," (third m1))))
    (define i (tobool (fourth m1)))
    ;(printf "a: ~a, b: ~a, i: ~a\n" a b i)
    (define ca (make-array make-array-bool a tbool))
    (define cb (make-array make-array-bool b tbool))
    (define p (make-pair-array-bool ca cb))
    (define outi (prog n p))
    outi)

  (time
   (call-with-input-file xfile
     (λ (xf-port)
       (for ([line (in-lines xf-port)])
         (run-single line))))))

(run-test (string->number (vector-ref (current-command-line-arguments) 0)))
