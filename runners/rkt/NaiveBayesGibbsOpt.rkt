#lang racket
(require hakrit)

(require sham
         hakrit
         ffi/unsafe
         racket/cmdline
         racket/runtime-path
         racket/date
         disassemble
         "discrete.rkt"
         "utils.rkt")

(define testname "NaiveBayesGibbs")

(define (run-test num-trials)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define newsd "news")
  (define wordsfile  (build-path input-dir newsd "words"))
  (define docsfile   (build-path input-dir newsd "docs"))
  (define topicsfile   (build-path input-dir newsd "topics"))

  (define rk-words (map string->number (file->lines wordsfile)))
  (define rk-docs (map string->number (file->lines docsfile)))
  (define rk-topics (map string->number (file->lines topicsfile)))

  (define words-size (length rk-words))
  (define docs-size (length rk-docs))
  (define topics-size (length rk-topics))
  (define num-docs (add1 (last rk-docs)))
  (define num-words (add1 (argmax identity rk-words)))
  (define num-topics (add1 (argmax identity rk-topics)))
  (printf "num-docs: ~a, num-words: ~a, num-topics: ~a\n" num-docs num-words num-topics)
  (printf "words-size: ~a, docs-size: ~a, topics-size: ~a\n" words-size docs-size topics-size)

  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" num-topics num-docs)))

  (define full-info
    `(((array-info . ((size . ,num-topics))))
      ((array-info . ((size . ,num-words))))
      ((array-info . ((size . ,num-docs)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-topics 1))))))))))
      ((array-info . ((size . ,words-size)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-words 1)))))))
                      (value . ,rk-words))))
      ((array-info . ((size . ,words-size)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-docs 1)))))))
                      (value . ,rk-docs))))
      ((nat-info . ((value-range . (0 . ,(- num-docs 1))))))))


  (define module-env (compile-file srcfile full-info))
  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)
  (define jit-val (curry rkt->jit module-env))
  (define set-index-nat-array (jit-get-function (string->symbol (format "set-index!$array<~a.~a>" num-topics 'nat)) module-env ))
  (define get-index-nat-array (jit-get-function (string->symbol (format "get-index$array<~a.~a>" num-topics 'nat)) module-env ))

  (define prog (jit-get-function 'prog module-env))

  (define topicPrior (list->cblock (build-list num-topics (const 0.0)) _double))
  (define wordPrior (list->cblock (build-list num-words (const 0.0)) _double))

  (define words (list->cblock rk-words _uint64))
  (define docs (list->cblock rk-docs _uint64))
  (define holdout-modulo 100)
  (define (holdout? i) (zero? (modulo i holdout-modulo)))
  ;; holding out only every 10, similar to haskell

  (define (update z docUpdate)
    (if (holdout? docUpdate)
        (prog topicPrior wordPrior z words docs docUpdate)
        (get-index-nat-array z docUpdate)))

  (define distf (discrete-sampler 0 (- num-topics 1)))
  (define zs (for/list ([orig-value rk-topics]
                        [i (in-range (length rk-topics))])
               (if  (holdout? i)
                    (distf)
                    orig-value)))
  (define z (list->cblock zs _uint64))

  (define (run out-port)
    (gibbs-timer (curry gibbs-sweep num-docs set-index-nat-array update)
                 z
                 (λ (tim sweeps state)
                   (printf "sweeped: ~a in ~a\n" sweeps (~r tim #:precision '(= 3)))
                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- num-docs 1))])
                     (fprintf out-port "~a, " (get-index-nat-array state i)))
                   (fprintf out-port "~a]\t" (get-index-nat-array state (- num-topics 1))))
                 #:min-sweeps 20
                 #:step-sweeps 1
                 #:min-time 0)
    (fprintf out-port "\n"))

  (printf "locked and loaded!\nrunning-test:\n")
  (call-with-output-file outfile #:exists 'update
    (λ (out-port)
      (for ([i (in-range num-trials)])
        (run out-port)))))

(module+ test
  (run-test 1))

(module+ main
    (define num-trials
      (command-line #:args (num-trials)
                    (string->number num-trials)))
  (run-test num-trials))
