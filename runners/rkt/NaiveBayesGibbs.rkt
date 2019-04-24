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

(define (run-test)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define newsd "news")
  (define wordsfile  (build-path input-dir newsd "words"))
  (define docsfile   (build-path input-dir newsd "docs"))
  (define topicsfile   (build-path input-dir newsd "topics"))

  (define words (map string->number (file->lines wordsfile)))
  (define docs (map string->number (file->lines docsfile)))
  (define topics (map string->number (file->lines topicsfile)))

  (define words-size (length words))
  (define docs-size (length docs))
  (define topics-size (length topics))

  (define num-docs (add1 (last docs)))
  (define num-words (add1 (argmax identity words)))
  (define num-topics (add1 (argmax identity topics)))

  (printf "num-docs: ~a, num-words: ~a, num-topics: ~a\n" num-docs num-words num-topics)
  (printf "words-size: ~a, docs-size: ~a, topics-size: ~a\n" words-size docs-size topics-size)

  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" num-topics num-docs)))

  (define module-env (compile-file srcfile))
  (define prog (get-prog module-env))

  (define topic-prior (sized-real-array (build-list num-topics (const 0.0))))
  (define word-prior (sized-real-array (build-list num-words (const 0.0))))

  (define c-words (sized-nat-array words))
  (define c-docs (sized-nat-array docs))

  (define holdout-modulo 10)
  (define (holdout? i) (zero? (modulo i holdout-modulo)))
  ;; holding out only every 10, similar to haskell

  (define (update z doc-update)
    (if (holdout? doc-update)
        (let ([newTopic (prog topic-prior word-prior z c-words c-docs doc-update)])
          newTopic)
        (sized-nat-array-ref z doc-update)))

  (define distf (discrete-sampler 0 (- num-topics 1)))
  (define zs (for/list ([orig-value topics]
                        [i (in-range (length topics))])
               (if (holdout? i) (distf) orig-value)))
  (define z (sized-nat-array zs))

  (define (accuracy)
    (define-values (correct total)
      (for/fold ([correct '()]
                 [total '()])
                ([i (in-range num-docs)]
                 [orig-value  topics]
                 #:when (holdout? i))
        (values (if (equal? orig-value (sized-nat-array-ref z i))
                    (cons i correct)
                    correct)
                (cons i total))))
    ;; (printf "correct: ~a\n" correct)
    (printf "\naccuracy: ~a/~a\n" (length correct) (length total))
    (* (/ (* (length correct) 1.0) (length total)) 100.0))
  (define (run out-port)
    (gibbs-timer (curry gibbs-sweep num-docs sized-nat-array-set! update)
                 z
                 (λ (tim sweeps state)
                   (printf "printing\n")
                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- num-docs 1))])
                     (fprintf out-port "~a, " (sized-nat-array-ref state i)))
                   (fprintf out-port "~a]\t" (sized-nat-array-ref state (- num-topics 1))))
                 #:min-sweeps 1
                 #:step-sweeps 1
                 #:min-time 0))
  (printf "locked and loaded!\nrunning-test:\n")
  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (printf "starting at: ~a\n" (current-date))
      (run out-port)
      (printf "finished at: ~a\n" (current-date)))))

(module+ test
  (run-test))

(module+ main
  (run-test))
