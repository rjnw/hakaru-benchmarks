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

(define (calc-accuracy)
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

  (define rkt-test (build-path output-dir testname "rkt" (format "~a-~a" num-topics num-docs)))
  (define hk-test (build-path output-dir testname "hk" (format "~a-~a" num-topics num-docs)))

  (define rkt-trials (file->lines rkt-test))
  (define hk-trials (file->lines hk-test))
  (define (get-zstates st)
    (map (λ (s) (map (compose inexact->exact string->number)
                     (regexp-match* #px"\\d\\.?\\d*" s))) (regexp-match* #rx"\\[(.*?)]" st)))
(define holdout-modulo 100)
  (define (holdout? i) (zero? (modulo i holdout-modulo)))
  (define (accuracy arr truth)
    (define-values (correct total)
      (for/fold ([correct '()]
                 [total '()])
                ([i (in-range (length truth))]
                 [orig-value  truth]
                 [val arr]
                 #:when (holdout? i))
        (printf "i: ~a, ~a==~a\n" i orig-value val)
        (values (if (equal? orig-value val)
                    (cons i correct)
                    correct)
                (cons i total))))
    (printf "total: ~a\n" total)
    (printf "correct: ~a\n" correct)
    (printf "\naccuracy: ~a\n" (/ (length correct) (length total)))
    (/ (* (length correct) 1.0) (length total)))
  (for ([rtr rkt-trials]
        [hkt hk-trials])
    (define r (get-zstates rtr))
    (define h (get-zstates hkt))
    (for ([rst r]
          [hst h])
      (printf "racket:\n")
      (define racc (accuracy rst rk-topics))
      (printf "haskell:\n")
      (define hacc (accuracy hst rk-topics))
      (printf "rkt: ~a, hkr: ~a\n" racc hacc)))

)

(calc-accuracy)
