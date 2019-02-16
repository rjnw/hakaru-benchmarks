#lang racket

(require hakrit
         hakrit/utils
         ffi/unsafe
         "utils.rkt")


(define testname "LinearRegression")

(define (run-test n)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define xfile  (build-path input-dir testname "dataX" (number->string n)))
  (define yfile  (build-path input-dir testname "y" (number->string n)))
  (define outfile (build-path output-dir testname "rkt" (number->string n)))

  (define lrinfo
    `((dataX . ((array-info ((size . ,n)))))
      (x6 . ((array-info . ((size . ,n)))))))

  (define module-env (compile-file srcfile '()))
  (define prog (get-prog module-env))

  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")
  (define x-list (map string->number (string-split (file->string xfile))))
  (define f (open-input-file yfile))
  (define xdata (make-sized-hakrit-array (map exact->inexact x-list) 'real))

  (define (run-single str out-port)
    (match-define (list _ y-str abv-str)  (regexp-match pair-array-regex str))
    (define y-list (map string->number (string-split y-str ",")))
    (match-define (list a b v) (map string->number (string-split abv-str ",")))
    (define y-array (make-sized-hakrit-array y-list 'real))
    (define before-ts (get-time))
    (define out-arr (prog xdata y-array))
    (define after-ts (get-time))

    (define out-a (fixed-hakrit-array-ref out-arr 'real 0))
    (define out-b (fixed-hakrit-array-ref out-arr 'real 1))
    (define out-noise (fixed-hakrit-array-ref out-arr 'real 2))
    (fprintf out-port "~a ~a [~a ~a ~a]\t\n" (- after-ts before-ts) 1 out-a out-b out-noise)

    ;; (printf "out-a: ~a, orig-a: ~a\n" out-a a)
    ;; (printf "out-b: ~a, orig-b: ~a\n" out-b b)
    ;; (printf "out-n: ~a, orig-n: ~a\n\n" out-noise v)
    )

  (call-with-input-file yfile
    (λ (yf-port)
      (call-with-output-file outfile #:exists 'replace
        (λ (out-port)
          (for ([line (in-lines yf-port)])
            (run-single line out-port)))))))

(module+ main
  (run-test (command-line #:args (n) (string->number n))))

(module+ test
 (run-test 10)
 ;; (run-test 100)
 ;; (run-test 1000)
 )
