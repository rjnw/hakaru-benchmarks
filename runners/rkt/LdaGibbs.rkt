#lang racket
(require hakrit)

(require hakrit
         hakrit/utils
         ffi/unsafe
         racket/cmdline
         racket/runtime-path
         disassemble
         "discrete.rkt"
         "utils.rkt")

(define testname "LdaGibbs")
(define news-dir "news")
(define (run-test (num-trials 1))
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))

  (define wordsfile  (build-path input-dir news-dir "words"))
  (define docsfile   (build-path input-dir news-dir "docs"))
  (define topicsfile   (build-path input-dir news-dir "topics"))

  (define rk-words (map string->number (file->lines wordsfile)))
  (define rk-docs (map string->number (file->lines docsfile)))
  (define rk-topics (map string->number (file->lines topicsfile)))

  (define words-size (length rk-words))
  (define docs-size (length rk-docs))
  (define topics-size (length rk-topics))
  (define num-docs (add1 (last rk-docs)))
  (define num-words (add1 (argmax identity rk-words)))
  (define num-topics (add1 (argmax identity rk-topics)))

  (define outfile (build-path output-dir testname "rkt" (format "~a-~a-~a" news-dir num-topics num-docs)))

  (define full-info
    `(((array-info . ((size . ,num-topics))))
      ((array-info . ((size . ,num-words))))
      ()
      ;; ((nat-info . ((value . ,num-docs))))
      ((array-info . ((size . ,words-size)
                      (value . ,rk-words))))
      ((array-info . ((size . ,words-size)
                      (value . ,rk-docs))))
      ((array-info . ((size . ,words-size))))
      ((nat-info . ((value-range . (0 . ,(- num-words 1))))))))

  (define prog (compile-hakaru srcfile full-info))

  (printf "num-docs: ~a, num-words: ~a, num-topics: ~a\n" num-docs num-words num-topics)
  (printf "words-size: ~a, docs-size: ~a, topics-size: ~a\n" words-size docs-size topics-size)

  (define topics-prior (list->cblock (build-list num-topics (const 0.0)) _double))
  (define words-prior (list->cblock (build-list num-words (const 0.0)) _double))

  (define words (list->cblock rk-words _uint64))
  (printf "made words\n")
  (define docs (list->cblock rk-docs _uint64))
  (printf "made docs\n")

  (define (update z word-update)
    (prog topics-prior words-prior num-docs words docs z word-update))

  (printf "made update\n")

  (define distf (discrete-sampler 0 (- num-topics 1)))
  (define z (malloc _uint64 words-size))
  (for ([i (in-range words-size)])
    (nat-array-set! z i (distf)))
  (printf "made zs\n")
  ;; (define z (list->cblock zs _uint64))

  (printf "running-trial\n")
  (define (run-single out-port)
    (define (snap tim position)
      (printf "taking snapshot: ~a, ~a\n" position tim)
      (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) position)
      (for ([i (in-range (- words-size 1))])
        (fprintf out-port "~a " (nat-array-ref z i)))
      (fprintf out-port "~a]\t" (nat-array-ref z (- words-size 1))))
    (define time0 (get-time))
    (define (loop i)
      (when (< i 100000)
        (when (zero? (modulo i 1000))
          (snap (elasp-time time0) i))
        (nat-array-set! z i (update z i))
        (loop (add1 i))))
    (loop 0)
    ;; (gibbs-timer (curry gibbs-sweep 1000 nat-array-set! update)
    ;;              z
    ;;              (λ (tim sweeps state)
    ;;                (printf "loging: ~a, ~a\n" sweeps tim)
    ;;                (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
    ;;                (for ([i (in-range (- words-size 1))])
    ;;                  (fprintf out-port "~a " (nat-array-ref state i)))
    ;;                (fprintf out-port "~a]\t" (nat-array-ref state (- words-size 1))))
    ;;              #:min-sweeps 10
    ;;              #:step-sweeps 1
    ;;              #:min-time 0
    ;;              #:step-time 0)
    (fprintf out-port "\n"))


  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (for ([i (in-range num-trials)])
        (run-single out-port)))))

(module+ main
    (define num-trials
      (command-line #:args ((num-trials "1"))
                    (string->number num-trials)))
  (run-test num-trials))
