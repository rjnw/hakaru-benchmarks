#lang racket

(require sham
         hakrit
         ffi/unsafe)



(define (run-test n)
  (define srcfile "../../testcode/hkrkt/LinearRegression.hkr")
  (define xfile (format "../../input/linearRegression/dataX/~a" n))
  (define yfile (format "../../input/linearRegression/y/~a" n))

  (define module-env (compile-file srcfile))

  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)

  (define prog (jit-get-function 'prog module-env))

  (define make-real-array (jit-get-function 'make$array<real> module-env))
  (define get-index-array (jit-get-function 'get-index$array<real> module-env))
  (define treal (jit-get-racket-type 'real module-env))

  (define (make-jit-array lst)
    (make-real-array  (length lst) (list->cblock (map exact->inexact lst) treal)))

  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")
  (define x-list (map string->number (string-split (file->string xfile))))
  (define f (open-input-file (string->path yfile)))

  (define (run-single str)
    (match-define (list _ y-str abv-str)  (regexp-match pair-array-regex str))
    (define y-list (map string->number (string-split y-str ",")))
    (match-define (list a b v) (map string->number (string-split abv-str ",")))
    (define x-array (make-jit-array x-list))
    (define y-array (make-jit-array y-list))
    (define out-arr (prog x-array y-array))
    (define out-a (get-index-array out-arr 0))
    (define out-b (get-index-array out-arr 1))
    (define out-noise (get-index-array out-arr 2))
    (printf "out-a: ~a, orig-a: ~a\n" out-a a)
    (printf "out-b: ~a, orig-b: ~a\n" out-b b)
    (printf "out-n: ~a, orig-n: ~a\n\n" out-noise v)
    (void))

  (call-with-input-file yfile
    (λ (yf-port)
      (for ([line (in-lines yf-port)])
        (run-single line)))))

(time (run-test 10))
