#lang racket
(require racket/runtime-path
         "plot-tsa.rkt"
         math/statistics
         racket/draw
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
(define true-topics-holdout
  (for/list ([tt true-topics]
             [i (in-range 0 (length true-topics))]
             #:when (holdout? i))
    tt))

(define (accuracy topics)
  (define-values (correct total)
    (for/fold ([correct-topics '()]
               [total-docs '()])
              ([i (in-range (length true-topics))]
               [true-topic true-topics]
               [predict-topic topics]
               #:when (holdout? i)
               )
      (values (if (equal? true-topic predict-topic)
                  (cons i correct-topics)
                  (begin
                    correct-topics))
              (cons i total-docs))))
  ;; (printf "full-accuracy: ~a, ~a\n" (length correct) (length total))
  (* 100 (/ (* (length correct) 1.0) (length total))))

(define num-topics 20)
(define num-docs 19997)

(define rkt-test (build-path output-dir testname "rkt" (format "~a-~a-~a" num-topics num-docs holdout-modulo)))
(define hk-test (build-path output-dir testname "hk" (format "~a-~a" num-topics num-docs)))
(define jags-test (build-path output-dir testname "jags" (format "~a-~a-adapt0" num-topics num-docs)))
(define augur-test (build-path output-dir testname "augur" (format "~a-~a-~a" num-topics num-docs holdout-modulo)))

(define (get-snapshots st)
  (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
  (define f (compose string->number))
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
  (map trial->tsa trials))

(define (fix-timings trials)
  (define-values (ntrials st ut ns)
    (for/fold ([ntrials '()]
               [sweept 0]
               [updatet 0]
               [nsweeps 1])
              ([tsa trials])
      (match-define (list tim sweep acc) tsa)
      (if (exact? sweep)
          (values (cons (list (+ (* 10 tim) updatet) nsweeps acc) ntrials)
                  0 (+ (* 10 tim) updatet) (add1 nsweeps))
          (values (cons (list (+ tim updatet sweept) nsweeps acc) ntrials)
                  (+ tim sweept) updatet (add1 nsweeps)))))
  (reverse ntrials))

(define (remove-warmup tsa)
  (for/list ([trial tsa])
    (define min-time (first (first trial)))
    (map (λ (shot) (list (- (first shot) min-time) (second shot) (third shot))) trial)))

(printf "loading trials\n")
(begin (define rkt-trials  (remove-warmup (str-trials->time-sweep-accuracy (file->lines rkt-test))))
       (define augur-trials  (remove-warmup (map fix-timings (str-trials->time-sweep-accuracy (file->lines augur-test)))))
       ;; (define hs-trials (str-trials->time-sweep-accuracy (file->lines hk-test)))
       )

(begin (define (jags-accuracy topics)
         (define-values (correct total)
           (for/fold ([correct-topics '()]
                      [total-docs '()])
                     ([i (in-range (length true-topics))]
                      [true-topic true-topics]
                      [predict-topic topics]
                      #:when (holdout? (add1 i))
                      )
             (values (if (equal? true-topic predict-topic)
                         (cons i correct-topics)
                         (begin
                           correct-topics))
                     (cons i total-docs))))
         ;; (printf "full-accuracy: ~a, ~a\n" (length correct) (length total))
         (* 100 (/ (* (length correct) 1.0) (length total))))
       (define (cleanup-jags trial)
         (define sshots (get-snapshots trial))
         (for/list ([shot sshots])
           (match-define (list tim sweep predict) shot)
           (list tim sweep (jags-accuracy (map sub1 predict)))))
       (define jags-trials  (remove-warmup (map cleanup-jags (file->lines jags-test)))))



(define (mean-time trials)
  (define (rec trials)
    (if (ormap empty? trials)
        '()
        (cons (let ([c (map car trials)])
                (cons (mean (map first c)) (map (λ (tsa) (cons (third tsa) (second tsa))) c) ))
              (rec (map cdr trials)))))
  (make-hash (rec trials)))

(define (trial-plot runner trials pts lcolor lstyle icolor istyle legend pstyle  (i 1) (point-size 3))
  ;; (define sta (run->sweep-time.accuracy pr))
  ;; (define smta (sweep-time.accuracy->sweep-mean$time.accuracy sta))
  (define tsa-map (mean-time trials))
  (define sta
    (sort
     (for/list ([(k v) tsa-map])
       (list (mean (map cdr v))
             k
             (mean (map car v))))
     (λ (v1 v2) (< (car v1) (car v2)))))
  (list

   (lines-interval
    (sort (for/list ([(k v) tsa-map])
            (list k (+ (mean (map car v))
                       (/ (stddev (map car v))
                          (sqrt (length (map car v)))))))
          (λ (v1 v2) (< (car v1) (car v2))))
    (sort (for/list ([(k v) tsa-map])
            (list k  (- (mean (map car v))
                        (/ (stddev (map car v))
                           (sqrt (length (map car v)))))))
          (λ (v1 v2) (< (car v1) (car v2))))
    #:color icolor #:style istyle
    #:line1-style 'transparent #:line2-style 'transparent
    #:alpha 0.2)

   (points
    (for/list ([(k v) tsa-map]
               #:when (if (equal? runner "augur")
                          (zero? (modulo (first (map cdr v)) 10))
                          #t))
      (list k (mean (map car v))))
    #:line-width 0.5
    #:size point-size #:color lcolor #:sym pstyle)

   (lines
    (sort (for/list ([(k v) tsa-map])
            (list k (mean (map car v))))
          (λ (v1 v2) (< (car v1) (car v2))))
    #:color lcolor #:style lstyle
    #:width 0.7
    #:label legend)
   ))

(printf "plotting data\n")

(begin
  ;; (define rkt-sta (run->sweep-time.accuracy rkt-trials))
  ;; (define augur-sta (run->sweep-time.accuracy augur-trials))
  ;; (define hs-sta (run->sweep-time.accuracy hs-trials))
  ;; (define jags-sta (run->sweep-time.accuracy jags-trials))
  ;; (define rkt-mta (sort (sweep-time.accuracy->mean$sweep.accuracy rkt-sta)
  ;;                       (λ (v1 v2) (< (car v1) (car v2)))))
  ;; (define augur-mta (sort (sweep-time.accuracy->mean$sweep.accuracy augur-sta)
  ;;                         (λ (v1 v2) (< (car v1) (car v2)))))
  ;; (define jags-mta (sort (sweep-time.accuracy->mean$time.accuracy jags-sta)
  ;;                        (λ (v1 v2) (< (car v1) (car v2)))))
  ;; (pretty-display rkt-mta)
  ;; (pretty-display augur-mta)

  (parameterize
      (;; [plot-x-transform log-transform]
       [plot-x-ticks (linear-ticks #:divisors '(5) #:base 10 #:number 2)]
       [plot-y-ticks (linear-ticks #:divisors '(10) #:base 10 #:number 2)]
       [plot-y-far-axis? #f]
       [plot-x-far-axis? #f]
       )
    (plot-file (append
                (trial-plot "rkt"
                            rkt-trials '()
                            (make-object color% 0 73 73) 'solid
                            (make-object color% 0 146 146) 'solid
                            "Hakaru" 'triangle)
                (trial-plot "augur"
                            augur-trials
                            ;; (map (curry filter (λ (tsa) (zero? (modulo (sub1 (second tsa)) 20)))) augur-trials)
                            '()
                            (make-object color% 146 73 0) 'solid
                            (make-object color% 0 0 0) 'solid
                            "AugurV2" 'bullet)
                (trial-plot "jags"
                            jags-trials
                            '()
                            (make-object color% 146 0 0) 'short-dash
                            (make-object color% 146 73 0) 'solid
                            "JAGS" 'diamond)

                ;; (lines rkt-mta #:color (make-object color% 0 73 73)  #:label "Hakaru-llvm" )
                ;; (lines augur-mta #:color (make-object color% 146 0 0)  #:label "AugurV2")
                ;; (lines jags-mta #:color (make-object color% 146 0 0)  #:label "jags" )
                ;; (points jags-mta #:size 6 #:color (make-object color% 146 0 0) #:sym 'diamond)
                ;; (points rkt-mta #:size 6 #:color (make-object color% 0 73 73) #:sym 'triangle)
                ;; (lines (first hk-points) #:color 5 #:label "haskell")


                )
               "NaiveBayesGibbs-Accuracy.pdf"

               #:y-min 45
               #:y-max 85
               #:x-max 400
               #:height 200
               #:width 400
               #:legend-anchor 'right
               #:x-label "Time in seconds"
               #:y-label "Accuracy in %")))
