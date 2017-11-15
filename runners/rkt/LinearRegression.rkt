#lang racket

(require sham
         hakrit
         ffi/unsafe
         "utils.rkt")


(define testname "LinearRegression")

(define (run-test n)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define xfile  (build-path input-dir testname "dataX" (number->string n)))
  (define yfile  (build-path input-dir testname "y" (number->string n)))
  (define outfile (build-path output-dir testname "rkt" (number->string n)))

  (define lrinfo (list
                  (list `(arrayinfo . ((size . ,n))) 'curry)
                  (list `(arrayinfo . ((size . ,n))))))

  (define module-env (compile-file srcfile lrinfo))

  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)

  (define prog1 (jit-get-function 'prog1 module-env))
  (define prog (jit-get-function 'prog module-env))

  (define make-real-array (jit-get-function (string->symbol (format "new-sized$array<~a.real>" n)) module-env))
  (define set-index-array (jit-get-function (string->symbol (format "set-index!$array<~a.real>" n)) module-env))

  (define get-index-array (jit-get-function 'get-index$array<real> module-env))
  (define treal (jit-get-racket-type 'real module-env))

  (define (make-array lst)
    (define arr (make-real-array))
    (for ([v lst]
          [i (in-range (length lst))])
      (set-index-array arr i (exact->inexact v)))
    arr)

  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")
  (define x-list (map string->number (string-split (file->string xfile))))
  (define f (open-input-file yfile))
  (define xdata (make-array x-list))
  (define curr-arg (prog1 xdata))

  ;; (define f1 (jit-get-function 'index$struct<array<8.real>.array<10.real>>.1 module-env))
  ;; (define f0 (jit-get-function 'index$struct<array<8.real>.array<10.real>>.0 module-env))
  ;; (define gi8 (jit-get-function 'get-index$array<8.real> module-env))
  ;; (define gi10 (jit-get-function 'get-index$array<10.real> module-env))
  ;; (define st1 (f0 curr-arg))
  ;; (define st2 (f1 curr-arg))

  (define (run-single str out-port)
    (match-define (list _ y-str abv-str)  (regexp-match pair-array-regex str))
    (define y-list (map string->number (string-split y-str ",")))
    (match-define (list a b v) (map string->number (string-split abv-str ",")))
    (define y-array (make-array y-list))
    (define before-ts (get-ts))
    (define out-arr (prog curr-arg y-array))
    (define after-ts (get-ts))

    (define out-a (get-index-array out-arr 0))
    (define out-b (get-index-array out-arr 1))
    (define out-noise (get-index-array out-arr 2))
    (fprintf out-port "~a ~a [~a ~a ~a]\t\n" (diff-ts before-ts after-ts) 1 out-a out-b out-noise))

    ;; (printf "out-a: ~a, orig-a: ~a\n" out-a a)
    ;; (printf "out-b: ~a, orig-b: ~a\n" out-b b)
    ;; (printf "out-n: ~a, orig-n: ~a\n\n" out-noise v))

  (call-with-input-file yfile
    (λ (yf-port)
      (call-with-output-file outfile #:exists 'replace
        (λ (out-port)
          (for ([line (in-lines yf-port)])
            (run-single line out-port)))))))

(module+ main
  (run-test (command-line #:args (n) (string->number n))))

(module+ test
;  (run-test 10)
;  (run-test 100)
  (run-test 1000))
