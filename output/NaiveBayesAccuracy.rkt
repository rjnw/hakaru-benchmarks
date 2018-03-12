#lang racket
(require hakrit)

(require racket/runtime-path
         "plot-tsa.rkt"
         plot)

(define testname "NaiveBayesGibbs")
(define input-dir "../input/")
(define  output-dir "./")

(define newsd "news")
(define wordsfile  (build-path input-dir newsd "words"))
(define docsfile   (build-path input-dir newsd "docs"))
(define topicsfile   (build-path input-dir newsd "topics"))

(define holdout-modulo 10)
(define (holdout? i) (zero? (modulo i holdout-modulo)))

(define true-topics (map string->number (file->lines topicsfile)))
(define (accuracy predict-topics)
  (define-values (correct total)
    (for/fold ([correct-topics '()]
               [total-docs '()])
              ([i (in-range (length true-topics))]
               [true-topic true-topics]
               [predict-topic predict-topics]
               #:when (holdout? i))
      (values (if (equal? true-topic predict-topic)
                  (cons predict-topic correct-topics)
                  correct-topics)
              (cons i total-docs))))
  (/ (* (length correct) 1.0) (length total)))

(define num-topics 20)
(define num-docs 19997)

(define rkt-test (build-path output-dir testname "rkt" (format "~a-~a" num-topics num-docs)))
(define hk-test (build-path output-dir testname "hk" (format "~a-~a" num-topics num-docs)))


(define (get-snapshots st)
  (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
  (define f (compose inexact->exact string->number))
  (map (λ (s) (match-define (list tim sweep state) s)
          (list (string->number tim)
                (f sweep)
                (map f (regexp-match* #px"\\d+\\.?\\d*" state))))
       snapshots))

(define (trial->tsa trial)
  (define sshots (get-snapshots trial))
  (for/list ([shot sshots])
    (define sweep (second shot))
    (define tim (first shot))
    (define acc (accuracy (third shot)))
    ;; (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
    (list tim sweep acc)))

(define (str-trials->time-sweep-accuracy trials)
  (for/list ([trial trials])
    (trial->tsa trial)))

(define rkt-lines (file->lines rkt-test))
(define rkt-trials (str-trials->time-sweep-accuracy rkt-lines))
;; (define hk-trials (str-trial->time-sweep-accuracy (file->lines hk-test)))


(define (plot-accuracy rkt-trials)
  (define sta (run->sweep-time.accuracy rkt-trials))
  (pretty-display sta)
  (define mta (sort (sweep-time.accuracy->mean-time.accuracy sta)
                    (λ (v1 v2) (< (car v1) (car v2)))))

  ;; (plot-file (list (lines (first rkt-points) #:color 2 #:y-min 0 #:y-max 100 #:label "hakrit" )
  ;;                  (lines (first hk-points) #:color 5 #:label "haskell"))
  ;;            "plot.png"
  ;;            #:x-label "sweep"
  ;;            #:y-label "accuracy"
  ;;            #:title "NaiveBayesGibbs"
  ;;            #:legend-anchor 'top-right)
  (plot (list  (lines mta #:color 2  #:label "hakrit" )
               ;; (lines (first hk-points) #:color 5 #:label "haskell")
               )
        #:y-min 0.8 #:y-max 1
        #:x-label "sweep"
        #:y-label "accuracy"
        #:title "NaiveBayesGibbs"))

;; (plot-accuracy rkt-trials)
;; hakrit std-dev 0.33
;; hakaru std-dev 2.4
