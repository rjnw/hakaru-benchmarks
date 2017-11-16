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
  (define gmminfo
    (list
     (list `(arrayinfo . ((size . ,classes)
                          (typeinfo . ((probinfo . ((constant . 0)))))
                          (constant . #t)))
           `(fninfo . (remove)))
     (list `(arrayinfo
             . ((size . ,points)
                (typeinfo
                 . ((natinfo
                     . ((valuerange . (0 . ,(- classes 1)))))))))
           `(fninfo . (movedown)))
     (list `(arrayinfo . ((size . ,points))))
     (list `(natinfo . ((valuerange . (0 . ,(- points 1))))))))


  (define infile  (build-path input-dir testname (format "~a-~a" classes points)))
  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" classes points)))

  (define module-env (compile-file srcfile gmminfo))
  ;(jit-dump-module module-env)
  (initialize-jit! module-env)
  (define init-rng (jit-get-function 'init-rng module-env))

  (init-rng)

  (define make-prob-array (jit-get-function (string->symbol (format "new-sized$array<~a.prob>" classes)) module-env))
  (define set-index-prob-array (jit-get-function (string->symbol (format "set-index!$array<~a.prob>" classes)) module-env))

  (define make-nat-array (jit-get-function (string->symbol (format "new-sized$array<~a.nat>" points)) module-env))
  (define set-index-nat-array (jit-get-function (string->symbol (format "set-index!$array<~a.nat>" points)) module-env))
  (define get-index-nat-array (jit-get-function (string->symbol (format "get-index$array<~a.nat>" points)) module-env))

  (define make-real-array (jit-get-function (string->symbol (format "new-sized$array<~a.real>" points)) module-env))
  (define set-index-real-array (jit-get-function (string->symbol (format "set-index!$array<~a.real>" points)) module-env))

  (define (make-as lst)
    (define arr (make-prob-array))
    (for ([v lst]
          [i (in-range (length lst))])
      (set-index-prob-array arr i (exact->inexact v)))
    arr)
  (define (make-zs lst)
    (define arr (make-nat-array))
    (for ([v lst]
          [i (in-range (length lst))])
      (set-index-nat-array arr i  v))
    arr)
  (define (make-ts lst)
    (define arr (make-real-array))
    (for ([v lst]
          [i (in-range (length lst))])
      (set-index-real-array arr i (exact->inexact v)))
    arr)

  (define distf (discrete-dist (build-list (- classes 1) values)))
  (define zs (build-list points (λ (i) (sample distf))))

  (define prog (jit-get-function 'prog module-env))
  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")
  (define (run-single str out-port)
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define ts (map string->number (regexp-split "," ts-str)))
    (define orig-zs (map  string->number (regexp-split "," zs-str)))
    (define tsc (make-ts ts))
    (define zsc (make-zs zs))
    (gibbs-timer (curry gibbs-sweep points set-index-nat-array (curry prog tsc))
                 zsc
                 (λ (tim sweeps state)
                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- points 1))])
                     (fprintf out-port "~a, " (get-index-nat-array state i)))
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
        (call-with-output-file outfile #:exists 'append
          (λ (out-port)
            (run-single line out-port)))))))




(module+ main ;;args
  (define-values (classes points) (command-line #:args (classes points) (values (string->number classes)
                                                                                (string->number points))))
  (run-test classes points))

(module+ test
  (run-test 3 10))
