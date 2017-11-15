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
  (printf "src: ~a" srcfile)
  (define gmminfo (list
                   (list `(arrayinfo . ((size . ,classes)
                                        (typeinfo . ((probinfo . ((valuerange . (1 . 1)))))))))
                   (list `(arrayinfo . ((size . ,points)
                                        (typeinfo . ((natinfo . ((valuerange . (0 . ,(- classes 1))))))))))
                   (list `(arrayinfo . ((size . ,points))) 'curry)
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

  (define prog3 (jit-get-function 'prog3 module-env))
  ;((array (prob (valuerange 1 . 1)) (size . 3)) (array (nat (valuerange 0 . 2)) (size . 10)) (array real (size . 10)))
  (define as (build-list classes (const (real->prob 1))))
  (define distf (discrete-dist (build-list (- classes 1) values)))
  (define zs (build-list points (λ (i) (sample distf))))
  ;(curry-arg (nat (valuerange 0 . 9)))
  (define prog (jit-get-function 'prog module-env))
  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")
  (define (run-single str out-port)
    (match-define (list _ ts-str zs-str) (regexp-match pair-array-regex str))
    (define ts (map string->number (regexp-split "," ts-str)))
    ;    (define zs (string->number (regexp-split "," zs-str)))
    (define curr-arg (prog3 (make-as as)
                            (make-zs zs)
                            (make-ts ts)))

    (printf "test: ~a\n" (prog curr-arg 4))
    (error 'stop)
    (gibbs-timer (curry gibbs-sweep points vector-set! (curry prog curr-arg))
                 (build-vector (const 1) points)
                 (curry fprintf out-port "~a ~a [~a]\t")))

  (call-with-input-file infile
    (λ (inp-port)
      (call-with-output-file outfile #:exists 'replace
        (λ (out-port)
          (for ([line (in-lines inp-port)])
            (run-single line out-port)))))))



(module+ main ;;args
  (define-values (classes points) (command-line #:args (classes points) (values (string->number classes)
                                                                                (string->number points))))
  (run-test classes points))

(module+ test
  (run-test 9 100))
