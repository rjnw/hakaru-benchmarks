#lang racket

(require sham
         hakrit
         ffi/unsafe racket/cmdline
        racket/runtime-path)

(define-runtime-path hksrc-dir "../../testcode/hkrkt/")
(define-runtime-path input-dir "../../input/")
(define-runtime-path output-dir "../../output/")

(define testname "ClinicalTrial")

(define (run-test n)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define xfile  (build-path input-dir testname (number->string n)))
  (define outfile (build-path output-dir testname "rkt" (number->string n)))
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
  (define total-wrong 0)
  (define (run-single str out-port)
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

    (define-values (outil realt cput gct)
      (time-apply prog (list n p)))

    (define outi (car outil))
    (fprintf out-port "~a ~a [~a]\n" cput 1 outi)
    (unless (equal? outi i) (set! total-wrong (+ total-wrong 1)))
    outi)

  (call-with-input-file xfile
    (λ (xf-port)
      (call-with-output-file outfile #:exists 'replace
        (λ (out-port)
           (for ([line (in-lines xf-port)])
             (run-single line out-port))))))
  (printf "total-wrong: ~a\n" total-wrong))

(module+ main
  (run-test (command-line #:args (n) (string->number n))))

(module+ test
  (run-test 1000))
