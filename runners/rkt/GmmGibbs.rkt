#lang racket

(require sham
         hakrit
         racket/cmdline
         racket/runtime-path
         "utils.rkt")
(require math)
(define testname "GmmGibbs")



(define (run-test classes points)
  (printf "c, ~a, p: ~a\n" classes points)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define gmminfo (list (list) (list) (list) (list) (list)))


  (define infile  (build-path input-dir testname (format "~a-~a" classes points)))
  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" classes points)))


  (define module-env (compile-file srcfile gmminfo))
  ;(jit-dump-module module-env)
  (optimize-module module-env #:opt-level 3)
  (initialize-jit! module-env #:opt-level 3)
  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)


  (define make-prob-array
    (jit-get-function (string->symbol (format "make$array<prob>")) module-env))
  (define new-sized-prob-array
    (jit-get-function (string->symbol (format "new-sized$array<prob>")) module-env))
  (define set-index-prob-array
    (jit-get-function (string->symbol (format "set-index!$array<prob>")) module-env))

  (define make-nat-array
    (jit-get-function (string->symbol (format "make$array<nat>")) module-env))
  (define new-sized-nat-array
    (jit-get-function (string->symbol (format "new-sized$array<nat>")) module-env))
  (define set-index-nat-array
    (jit-get-function (string->symbol (format "set-index!$array<nat>")) module-env))
  (define get-index-nat-array
    (jit-get-function (string->symbol (format "get-index$array<nat>")) module-env))

  (define make-real-array
    (jit-get-function (string->symbol (format "make$array<real>")) module-env))
  (define new-sized-real-array
    (jit-get-function (string->symbol (format "new-sized$array<real>")) module-env))
  (define set-index-real-array
    (jit-get-function (string->symbol (format "set-index!$array<real>" )) module-env))

  (define prog (jit-get-function 'prog module-env))


  (define real2prob (jit-get-function (string->symbol "real2prob") module-env))

  (define stdev (real2prob 14.0))


  (define as (new-sized-prob-array classes))
  (for ([i (in-range classes)])
    (set-index-prob-array as i 0.0))

  (define (make-zs lst)
    (define arr (new-sized-nat-array (length lst)))
    (for ([v lst]
          [i (in-range (length lst))])
      (set-index-nat-array arr i  v))
    arr)

  (define (make-ts lst)
    (define arr (new-sized-real-array (length lst)))
    (for ([v lst]
          [i (in-range (length lst))])
      (set-index-real-array arr i (exact->inexact v)))
    arr)

  (define distf (discrete-dist (build-list (- classes 1) values)))
  (define zs (build-list points (λ (i) (sample distf))))

  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

  (define (run-single str out-port)
    (printf "running single\n")
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define ts (map string->number (regexp-split "," ts-str)))
    (define orig-zs (map  string->number (regexp-split "," zs-str)))
    (define tsc (make-ts ts))
    (define zsc (make-zs zs))

    (define (update z doc)
      (prog stdev as z tsc doc))
    (define (printer)
      (printf "state: ")
      (for ([i (in-range (- points 1))])
        (printf  "~a " (get-index-nat-array zsc i)))
      (printf "\n"))
    (gibbs-timer (curry gibbs-sweep points printer set-index-nat-array update)
                 zsc
                 (λ (tim sweeps state)
                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- points 1))])
                     (fprintf out-port "~a " (get-index-nat-array state i)))
                   (fprintf out-port "~a]\t" (get-index-nat-array state (- points 1)))))
    (fprintf out-port "\n")
    (printf "final state: ~a, \n\tactual state: ~a\n"
            (for/list ([i (in-range points)])
              (get-index-nat-array zsc i))
            orig-zs))

  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (fprintf out-port "")))

  (call-with-input-file infile
    (λ (inp-port)
      (for ([line (in-lines inp-port)])
        (printf "do")
        (call-with-output-file outfile #:exists 'append
          (λ (out-port)
            (run-single line out-port)))))))




(module+ main ;;args
  (define-values (classes points)
    (command-line #:args (classes points)
                  (values (string->number classes)
                          (string->number points))))
  (run-test classes points))

(module+ test
  (run-test 6 10))
