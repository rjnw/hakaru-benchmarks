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
         "gmm-utils.rkt")

(define testname "NaiveBayesGibbs")

(define (run-test num-trials trial-sweeps trial-time holdout-modulo)
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

  (define outfile (build-path output-dir testname "rkt" (format "~a-~a-~a" num-topics num-docs holdout-modulo)))

  (define full-info
    `((topic_prior . ((array-info . ((size . ,num-topics)))))
      (word_prior . ((array-info . ((size . ,num-words)))))
      (z . ((array-info . ((size . ,num-docs)
                           ;; (elem-info . ((nat-info
                           ;;            . ((value-range
                           ;;                . (0 . ,(- num-topics 1)))))))
                           ))))
      (w . ((array-info . ((size . ,words-size)
                           ;; (elem-info . ((nat-info . ((value-range . (0 . ,(- num-words 1)))))))
                           ;; (value . ,words)
                           ))))
      (doc . ((array-info . ((size . ,words-size)
                             ;; (elem-info . ((nat-info
                             ;;                . ((value-range
                             ;;                    . (0 . ,(- num-docs 1)))))))
                             ;; (value . ,docs)
                             ))))
      ;; (docUpdate . ((nat-info . ((value-range . (0 . ,(- num-docs 1)))))))
      ))


  (define module-env (compile-file srcfile full-info))
  (define prog (get-prog module-env))
  (printf "compiled prog\n")

  (define topicPrior (list->cblock (build-list num-topics (const 0.0)) _double))
  (define wordPrior (list->cblock (build-list num-words (const 0.0)) _double))

  (define words (list->cblock rk-words _uint64))
  (define docs (list->cblock rk-docs _uint64))
  (printf "loaded words, docs\n")
  (define (holdout? i) (zero? (modulo i holdout-modulo)))
  ;; holding out only every 10, similar to haskell

  (define (update z docUpdate)
    (if (holdout? docUpdate)
        (begin
          (prog topicPrior wordPrior z words docs docUpdate))
        (get-index-nat-array z docUpdate)))

  (define distf (discrete-sampler 0 (- num-topics 1)))
  (define zs (for/list ([orig-value rk-topics]
                        [i (in-range (length rk-topics))])
               (if  (holdout? i)
                    (distf)
                    orig-value)))
  (define z (list->cblock zs _uint64))

  (define (run out-port)
    (define (printer tim sweeps state)
      (printf "sweeped: ~a in ~a\n" sweeps (~r tim #:precision '(= 3)))
      (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
      (for ([i (in-range (- num-docs 1))])
        (fprintf out-port "~a " (get-index-nat-array state i)))
      (fprintf out-port "~a]\t" (get-index-nat-array state (- num-docs 1))))
    (define sweeper (curry gibbs-sweep num-docs set-index-nat-array update))
    (gibbs-timer sweeper z printer
                 #:min-sweeps trial-sweeps
                 #:step-sweeps 1
                 #:min-time trial-time)
    (fprintf out-port "\n"))

  (printf "locked and loaded!\nrunning-test:\n")
  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (for ([i (in-range num-trials)])
        (for ([i (in-range (length rk-topics))]
              #:when (holdout? i))
          (nat-array-set! z i (distf)))
        (run out-port)))))

(module+ test
  (run-test 1 10 10))

(module+ main
  (define-values (num-trials trial-sweeps trial-time holdout-modulo)
      (command-line #:args (num-trials trial-sweeps trial-time holdout-modulo)
                    (values (string->number num-trials)
                            (string->number trial-sweeps)
                            (string->number trial-time)
                            (string->number holdout-modulo))))
  (run-test num-trials trial-sweeps trial-time holdout-modulo))
