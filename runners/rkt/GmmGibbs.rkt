#lang racket

(require sham
         hakrit
         racket/cmdline
         racket/runtime-path
         "utils.rkt")
(require math)

(define testname "GmmGibbs")
(define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

(define (run-test classes points)
  (printf "c, ~a, p: ~a\n" classes points)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define gmm-emptyinfo (list (list) (list) (list) (list) (list)))
  (define infile  (build-path input-dir testname (format "~a-~a" classes points)))
  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" classes points)))

  (define module-env (compile-file srcfile gmminfo))
  (define jit-val (curry jit->rkt module-env))

  ;(jit-dump-module module-env)
  (optimize-module module-env #:opt-level 3)
  (initialize-jit! module-env #:opt-level 3)

  (define init-rng (jit-get-function 'init-rng module-env))
  (define prog (jit-get-function 'prog module-env))
  (init-rng)

  (define stdev (jit-val 'prob 14.0))
  (define as (jit-val '(array prob) (build-list classes (const 1.0))))

  (define (run-single str out-port)
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define orig-zs (map  string->number (regexp-split "," zs-str)))
    (define zs (build-list points (λ (i) (sample (discrete-dist (build-list (- classes 1) values))))))

    (define tsc (jit-val '(array real) (map string->number (regexp-split "," ts-str))))
    (define zsc (jit-val '(array nat) zs))

    (define (update z doc)
      (prog stdev as z tsc doc))

    (gibbs-timer (curry gibbs-sweep points set-index-nat-array update)
                 zsc
                 (λ (tim sweeps state)
                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- points 1))])
                     (fprintf out-port "~a " (get-index-nat-array state i)))
                   (fprintf out-port "~a]\t" (get-index-nat-array state (- points 1)))))
    (fprintf out-port "\n"))

  (call-with-input-file infile
    (λ (inp-port)
      (call-with-output-file outfile #:exists 'replace
        (λ (out-port)
          (for ([line (in-lines inp-port)])
            (run-single line out-port)))))))




(module+ main ;;args
  (define-values (classes points)
    (command-line #:args (classes points)
                  (values (string->number classes)
                          (string->number points))))
  (run-test classes points))

(module+ test
  (run-test 6 10))
