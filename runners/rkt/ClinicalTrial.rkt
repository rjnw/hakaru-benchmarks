#lang racket

(require sham
         hakrit
         ffi/unsafe racket/cmdline
        racket/runtime-path)

(define-runtime-path CT.hkr "../../testcode/hkrkt/ClinicalTrial.hkr")
(define module-env (debug-file CT.hkr))

(define init-rng (jit-get-function 'init-rng module-env))
(init-rng)
(define prog (jit-get-function 'prog module-env))
(define tbool (jit-get-racket-type 'bool module-env))
(define make-boolarr-pair (jit-get-function 'make$pair<array<bool>*.array<bool>*> module-env))
(define make-bool-array (jit-get-function 'make$array<bool> module-env))

(define n (command-line #:args (n) (string->number n)))
(define-runtime-path xfile "../../input/clinicalTrial/")
(define xdata (file->lines (build-path xfile (number->string n))))

(define (tobool str)
  (match str
    ["True" 1]
    ["False" 0]))

(define (make-carray f t l)
  (f (length l) (list->cblock l t)))

(define total-not-equal 0)
(define (run-test str)
  (define m1 (regexp-match "\\(\\[(.*)\\],\\[(.*)\\]\\),(.*)\\)" str))
  (when (< (length m1) 4)
    (error "matching line from input"))
  (define a (map tobool (regexp-split "," (second m1))))
  (define b (map tobool (regexp-split "," (third m1))))
  (define i (tobool (fourth m1)))
  ;(printf "a: ~a, b: ~a, i: ~a\n" a b i)
  (define ca (make-carray make-bool-array tbool a))
  (define cb (make-carray make-bool-array tbool b))
  (define p (make-boolarr-pair ca cb))
  (define result (prog n p))
  (unless (equal? i (prog n p))
         (set! total-not-equal (+ total-not-equal 1))
         #;
    (printf "wrong!\n")))

(time (for ([data xdata])
          (run-test data)))
(printf "total not equal: ~a\n" total-not-equal)
;;its always half of total don't know if that is supposed to happen or our implementation
;; is wrong as there are only two outputs
