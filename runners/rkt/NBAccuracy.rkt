#lang racket
(require hakrit)

(require racket/runtime-path
         plot
         "utils.rkt")

(define testname "NaiveBayesGibbs")

(define (calc-accuracy)
  (define newsd "news")
  (define wordsfile  (build-path input-dir newsd "words"))
  (define docsfile   (build-path input-dir newsd "docs"))
  (define topicsfile   (build-path input-dir newsd "topics"))

  ;; (define rk-words (map string->number (file->lines wordsfile)))
  ;; (define rk-docs (map string->number (file->lines docsfile)))
  (define rk-topics (map string->number (file->lines topicsfile)))

  ;; (define words-size (length rk-words))
  ;; (define docs-size (length rk-docs))
  ;; (define topics-size (length rk-topics))
  ;; (define num-docs (add1 (last rk-docs)))
  ;; (define num-words (add1 (argmax identity rk-words)))
  ;; (define num-topics (add1 (argmax identity rk-topics)))

  (define num-topics 20)
  (define num-docs 19997)

  (define rkt-test (build-path output-dir testname "rkt" (format "~a-~a" num-topics num-docs)))
  (define hk-test (build-path output-dir testname "hk" (format "~a-~a" num-topics num-docs)))

  (define rkt-trials (file->lines rkt-test))
  (define hk-trials (file->lines hk-test))
  (define (get-snapshots st)
    (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
    (define f (compose inexact->exact string->number))
    (map (λ (s) (match-define (list tim sweep state) s)
            ;; (print state)
            (list (string->number tim)
                  (f sweep)
                  (map f (regexp-match* #px"\\d+\\.?\\d*" state))))
         snapshots))

  (define holdout-modulo 10)
  (define (holdout? i) (zero? (modulo i holdout-modulo)))
  (define (accuracy arr truth)
    (define-values (correct total)
      (for/fold ([correct '()]
                 [total '()])
                ([i (in-range (length truth))]
                 [orig-value  truth]
                 [val arr]
                 #:when (holdout? i))
        (values (if (equal? orig-value val)
                    (cons i correct)
                    correct)
                (cons i total))))
    (printf "accuracy: ~a/~a\n" (length correct) (length total))
    (* 100 (/ (* (length correct) 1.0) (length total))))

  (define (get-time-accuracy trials)
    (for/list ([rtr trials])
      (define sshots (get-snapshots rtr))
      (for/list ([shot sshots])
        (define sweep (second shot))
        (define tim (first shot))
        (define acc (accuracy (third shot) rk-topics))
        (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
        (list sweep acc))))

  (printf "racket:\n")
  (define rkt-points (get-time-accuracy rkt-trials))

  (printf "haskell:\n")
  (define hk-points (get-time-accuracy hk-trials))

;; (plot-file (list (lines (first rkt-points) #:color 2 #:y-min 0 #:y-max 100 #:label "hakrit" )
  ;;                  (lines (first hk-points) #:color 5 #:label "haskell"))
  ;;            "plot.png"
  ;;            #:x-label "sweep"
  ;;            #:y-label "accuracy"
  ;;            #:title "NaiveBayesGibbs"
  ;;            #:legend-anchor 'top-right)
  (plot (list  (lines (first rkt-points) #:color 2 #:y-min 0 #:y-max 100 #:label "hakrit" )
              (lines (first hk-points) #:color 5 #:label "haskell"))
        #:x-label "sweep"
        #:y-label "accuracy"
        #:title "NaiveBayesGibbs"))

(calc-accuracy)
;; hakrit std-dev 0.33
;; hakaru std-dev 2.4
