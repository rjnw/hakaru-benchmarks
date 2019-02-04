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
    `((as . ((array-info . ((size . ,classes)))))
      (z . ((array-info . ((size . ,points)))))
      (t . ((array-info . ((size . ,points)))))
      ;; ((nat-info . ((value-range . (0 . ,(- points 1))))))
      ))

  (define infile  (build-path input-dir testname (format "~a-~a" classes points)))
  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" classes points)))

  (define module-env (compile-file srcfile full-info))
  (define prog (get-prog module-env))

  (define stdev (real->prob '14.0))
  (define as (make-fixed-hakrit-array (build-list classes (const 0.0)) 'real))

  (define (run-single str out-port)
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define orig-zs (map  string->number (regexp-split "," zs-str)))
    (define distf (discrete-sampler 0 (- classes 1)))
    (define zs (build-list points (λ (a) (distf))))

    (define tsc (make-fixed-hakrit-array (map string->number (regexp-split "," ts-str)) 'real))
    (define zsc (make-fixed-hakrit-array zs 'nat))
    (define (update z doc)
      (prog stdev as z tsc doc))

    (define (printer tim sweeps state)
      (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
      (for ([i (in-range points)])
        (fprintf out-port "~a " (fixed-hakrit-array-ref state 'nat i)))
      (fprintf out-port "~a]\t" (fixed-hakrit-array-ref state 'nat (sub1 points))))


    (define spr (curry gibbs-sweep points (λ (arr i v) (fixed-hakrit-array-set! arr 'nat i v)) update))
    (gibbs-timer spr zsc printer #:min-time 2 #:step-time 0.01 #:min-sweeps 0 #:step-sweeps 1)

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
