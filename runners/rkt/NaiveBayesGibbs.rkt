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

(define (run-test)
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

  (define empty-info '(() () () () () ()))
  (define full-info
    `(((array-info . ((size . ,num-topics)
                      (elem-info . ((prob-info . ((constant . 0)))))))
       (attrs . (constant)))
      ((array-info . ((size . ,num-words)
                      (elem-info . ((prob-info . ((constant . 0)))))))
       (attrs . (constant)))
      ((array-info . ((size . ,num-docs)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-topics 1))))))))))
      ((array-info . ((size . ,words-size)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-words 1)))))))
                      (value . ,rk-words)))
       (attrs . (constant)))
      ((array-info . ((size . ,words-size)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-docs 1)))))))
                      (value . ,rk-docs)))
       (attrs . (constant)))
      ((nat-info . ((value-range . (0 . ,(- num-docs 1))))))))


  (define module-env (compile-file srcfile empty-info))
  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)
  (define prog (jit-get-function 'prog module-env))
  (define jit-val (curry rkt->jit module-env))

  (define make-prob-array (get-function module-env 'make '(array prob)))
  (define new-sized-prob-array (get-function module-env 'new '(array prob)))
  (define set-index-prob-array (get-function module-env 'set-index! '(array prob)))

  (define make-nat-array (get-function module-env 'make '(array nat)))
  (define new-sized-nat-array (get-function module-env 'new '(array nat)))
  (define set-index-nat-array (get-function module-env 'set-index! '(array nat)))
  (define get-index-nat-array (get-function module-env 'get-index '(array nat)))

  (define make-real-array (get-function module-env 'make '(array real)))
  (define new-sized-real-array (get-function module-env 'new '(array real)))
  (define set-index-real-array (get-function module-env 'set-index! '(array real)))



  (define topicPrior (new-sized-prob-array num-topics))
  (for ([i (in-range num-topics)])
    (set-index-prob-array topicPrior i 0.0))

  (define wordPrior (new-sized-prob-array num-words))
  (for [(i (in-range num-words))]
    (set-index-prob-array wordPrior i 0.0))

  (define words (new-sized-nat-array words-size))
  (for ([i (in-range words-size)]
        [v rk-words])
    (set-index-nat-array words i v))
  (define docs (new-sized-nat-array docs-size))
  (for ([i (in-range docs-size)]
        [v rk-docs])
    (set-index-nat-array docs i v))

  (define holdout-modulo 100)
  (define (holdout? i) (zero? (modulo i holdout-modulo)))
  ;; holding out only every 10, similar to haskell

  (define (update z docUpdate)
    (if (holdout? docUpdate)
        (let ([newTopic (prog topicPrior wordPrior z words docs docUpdate)])
          newTopic)
        (get-index-nat-array z docUpdate)))

  (define distf (discrete-sampler 0 (- num-topics 1)))
  (define zs (for/list ([orig-value rk-topics]
                        [i (in-range (length rk-topics))])
               (if  (holdout? i)
                    (distf)
                    orig-value)))
  (define z (make-nat-array num-docs (list->cblock zs _uint64)))
  (define (accuracy)
    (define-values (correct total)
      (for/fold ([correct '()]
                 [total '()])
                ([i (in-range num-docs)]
                 [orig-value  rk-topics]
                 #:when (holdout? i))
        (values (if (equal? orig-value (get-index-nat-array z i))
                    (cons i correct)
                    correct)
                (cons i total))))
    ;; (printf "correct: ~a\n" correct)
    (printf "\naccuracy: ~a/~a\n" (length correct) (length total))
    (* (/ (* (length correct) 1.0) (length total)) 100.0))
  (define (run out-port)
    (gibbs-timer (curry gibbs-sweep num-docs set-index-nat-array update)
                 z
                 (λ (tim sweeps state)

                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- num-docs 1))])
                     (fprintf out-port "~a, " (get-index-nat-array state i)))
                   (fprintf out-port "~a]\t" (get-index-nat-array state (- num-topics 1))))
                 #:min-sweeps 1
                 #:step-sweeps 1))
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
