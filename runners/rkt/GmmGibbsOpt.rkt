#lang racket

(require hakrit
         hakrit/utils
         racket/cmdline
         racket/runtime-path
         "gmm-utils.rkt"
         "discrete.rkt")

(define testname "GmmGibbs")
(define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

(define (run-test classes points)
  (printf "c, ~a, p: ~a\n" classes points)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define full-info
    `(()
      ((array-info . ((size . ,classes))))
      ((array-info . ((size . ,points))))
      ((array-info . ((size . ,points)))
       ;; (attrs . (constant))
       ;; (value . ,(car input))
       )
      ((nat-info . ((value-range . (0 . ,(- points 1))))))))

  (define infile  (build-path input-dir testname (format "~a-~a" classes points)))
  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" classes points)))

  (define prog (compile-hakaru srcfile full-info))

  (define stdev (real->prob '14.0))
  (define as (real-array (build-list classes (const 0.0))))

  (define (run-single str out-port)
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define orig-zs (map  string->number (regexp-split "," zs-str)))
    (define distf (discrete-sampler 0 (- classes 1)))
    (define zs (build-list points (λ (a) (distf))))

    (define tsc (real-array (map string->number (regexp-split "," ts-str))))
    (define zsc (nat-array zs))
    (define (update z doc)
      (prog stdev as z tsc doc))

    (define (printer tim sweeps state)
      (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
      (for ([i (in-range points)])
        (fprintf out-port "~a " (nat-array-ref state i)))
      (fprintf out-port "~a]\t" (nat-array-ref state (sub1 points))))


    (define spr (curry gibbs-sweep points nat-array-set! update))

    (gibbs-timer spr zsc printer #:min-time 12 #:step-time 0.01 #:min-sweeps 0 #:step-sweeps 1)

    (fprintf out-port "\n"))
  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (for ([line (file->lines infile)])
        (run-single line out-port)))))

(module+ main
  (define-values (classes points)
    (command-line #:args (classes points)
                  (values (string->number classes)
                          (string->number points))))
  (run-test classes points))

(module+ test
  (run-test 6 10))
