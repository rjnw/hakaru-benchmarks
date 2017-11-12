#lang racket

(require sham
         hakrit)


(define hkrsrc "../../testcode/hkrkt/~a.hkr")
(define testname "GmmGibbs")
(define inputdir "../../input/")

(define (run-test n)
  (define srcfile (format hksrc testname))
  (define xfile (format (string-append inputdir "dataX/~a") n))
  (define yfile (format (string-append inputdir "y/~a") n))

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

  (define treal (jit-get-racket-type 'real module-env))
  (define tprob (jit-get-racket-type 'prob module-env))
  (define tnat (jit-get-racket-type 'nat module-env))

  (define (make-array f lst type)
    (f  (length lst) (list->cblock lst type)))

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
