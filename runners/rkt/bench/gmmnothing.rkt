#lang racket

(require sham
         hakrit
         math/statistics
         racket/cmdline
         ffi/unsafe
         racket/runtime-path
         "../utils.rkt"
         "../discrete.rkt")


(define testname "GmmGibbs")
(define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

(define (run-test classes points)
  (printf "c, ~a, p: ~a\n" classes points)
  (define srcfile (build-path hksrc-dir (string-append "GmmGibbsNoSummary" ".hkr")))
  (define empty-info '(() () () () () ()))
  (define full-info
    `(()
      ((array-info . ((size . ,classes)
                      ;; (elem-info . ((prob-info . ((constant . 1.0)))))
                      ))
       ;; (attrs . (constant))
       )
      ((array-info
        . ((size . ,points)
           (elem-info
            . ((nat-info
                . ((value-range . (0 . ,(- classes 1))))))))))
      ((array-info . ((size . ,points)))
       ;; (attrs . (constant))
       ;; (value . ,(car input))
       )
      ((nat-info . ((value-range . (0 . ,(- points 1))))))))


  (define infile  (build-path input-dir testname (format "~a-~a" classes points)))
  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" classes points)))


  (define module-env (compile-file srcfile empty-info))

  (define jit-val (curry rkt->jit module-env))

  ;; (jit-dump-module module-env)
  ;; (optimize-module module-env #:opt-level 3)
  ;; (initialize-jit! module-env #:opt-level 3)

  (define init-rng  (jit-get-function 'init-rng module-env))
  (define prog (jit-get-function 'prog module-env))
  (init-rng)

  (define stdev (jit-val 'prob 14.0))
  (define as (jit-val '(array prob) (build-list classes (const 1.0))))
  ;; (define as (list->cblock (build-list classes (const 0.0)) _double))


  (define (run-bench str)
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define orig-zs (map  string->number (regexp-split "," zs-str)))
    (define distf (discrete-sampler 0 (- classes 1)))
    (define zs (build-list points (λ (a) (distf))))

    (define tsc (jit-val '(array real) (map string->number (regexp-split "," ts-str))))
    (define zsc (jit-val '(array nat) zs))

    ;; (define tsc (list->cblock (map string->number (regexp-split "," ts-str)) _double))
    ;; (define zsc (list->cblock zs _uint64))

    (define (sweep)
      (for ([doc (in-range 1)])
        (prog stdev as zsc tsc doc)))

    (define (get-run-time)
      (define d (cdr (for/list ([s (in-range 100)])
                       (let ([t (get-time)])
                         (begin
                           (sweep)
                           (* (elasp-time t)
                              10000))))))
      (cons (mean d) (/ (stddev d)
                        (sqrt (length d)))))
    (pretty-display (get-run-time))) ;too slow to calculate

  (run-bench (car (file->lines infile))))

 (run-test 50 10000)
