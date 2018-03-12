#lang racket

(require sham
         hakrit
         racket/cmdline
         ffi/unsafe
         racket/runtime-path
         "utils.rkt"
         "discrete.rkt")


(define testname "GmmGibbs")
(define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

(define (run-test classes points)
  (printf "c, ~a, p: ~a\n" classes points)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
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


  (define module-env (compile-file srcfile full-info))

  (define jit-val (curry rkt->jit module-env))

  ;; (jit-dump-module module-env)
  ;; (optimize-module module-env #:opt-level 3)
  ;; (initialize-jit! module-env #:opt-level 3)

  (define init-rng (time (jit-get-function 'init-rng module-env)))
  (define prog (jit-get-function 'prog module-env))
  (init-rng)
  (printf "current-process-milliseconds: ~a\n" (current-process-milliseconds))
  (define set-index-nat-array (jit-get-function (string->symbol (format "set-index!$array<~a.~a>" classes 'nat)) module-env ))
  (define get-index-nat-array (jit-get-function (string->symbol (format "get-index$array<~a.~a>"  classes 'nat)) module-env ))
  (define stdev (jit-val 'prob 14.0))
  (define as (list->cblock (build-list classes (const 0.0)) _double))



  (define (run-single str out-port)
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define orig-zs (map  string->number (regexp-split "," zs-str)))
    (define distf (discrete-sampler 0 (- classes 1)))
    (define zs (build-list points (λ (a) (distf))))

    ;; (define tsc (jit-val '(array real) (map string->number (regexp-split "," ts-str))))
    ;; (define zsc (jit-val '(array nat) zs))

    (define tsc (list->cblock (map string->number (regexp-split "," ts-str)) _double))
    (define zsc (list->cblock zs _uint64))

    (define (update z doc)
      (prog stdev as z tsc doc))

    ;; (update zsc 0)
    (define (printer tim sweeps state)
      (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
      (for ([i (in-range points)])
        (fprintf out-port "~a " (get-index-nat-array state i)))
      (fprintf out-port "~a]\t" (get-index-nat-array state (- points 1))))
    (define sweeper (curry gibbs-sweep points set-index-nat-array update))

    (gibbs-timer sweeper zsc printer #:min-time 0 #:step-time 0.01 #:min-sweeps 1 #:step-sweeps 1)
    (fprintf out-port "\n"))
  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (for ([line (file->lines infile)])
        (run-single line out-port)))))

(module+ main ;;args
  (define-values (classes points)
    (command-line #:args (classes points)
                  (values (string->number classes)
                          (string->number points))))
  (run-test classes points))

(module+ test
  (run-test 6 10))
