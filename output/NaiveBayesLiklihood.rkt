#lang racket
(require racket/runtime-path
         "plot-tsa.rkt"
         math/statistics
         racket/draw
         plot)

(define log-scales '("" "10^3" "10^6" "10^9" "10^12"))
(define log-formats '("~w.~fx~s" "-~w.~f ~s" "~$0"))
(define log-ticks (currency-ticks-format #:kind 'log #:scales log-scales #:formats log-formats))

(define testname "NaiveBayesGibbs")
(define input-dir "../input/")

(define  output-dir "./accuracies/")
(define holdout-modulo 10)

(define num-topics 20)
(define num-docs 19997)
(define rkt-test (build-path output-dir testname "rkt" (format "~a-~a-~a" num-topics num-docs holdout-modulo)))
;; (define hk-test (build-path output-dir testname "hk" (format "~a-~a" num-topics num-docs)))
(define jags-test (build-path output-dir testname "jags" (format "~a-~a-~a" num-topics num-docs holdout-modulo)))
(define augur-test (build-path output-dir testname "augur" (format "~a-~a-~a" num-topics num-docs holdout-modulo)))

(define (get-snapshots st)
  (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
  (define f (compose string->number))
  (map (λ (s) (match-define (list tim sweep state) s)
          ;; (pretty-display state)
          (list (string->number tim)
                (f sweep)
                (f state)))
       snapshots))


(define (remove-warmup tsa)
  (for/list ([trial tsa])
    (define min-time (first (first trial)))
    (map (λ (shot) (list (- (first shot) min-time) (second shot) (third shot))) trial)))
(define (fix-timings trials)
  (define-values (ntrials st ut ns)
    (for/fold ([ntrials '()]
               [sweept 0]
               [updatet 0]
               [nsweeps 1])
              ([tsa trials])
      (match-define (list tim sweep acc) tsa)
          (values (cons (list (+ (* 10 tim) updatet) nsweeps acc) ntrials)
                  0 (+ (* 10 tim) updatet) (add1 nsweeps))))
  (reverse ntrials))

(define rkt-trials (remove-warmup (map get-snapshots (file->lines rkt-test))))
(define jags-trials (remove-warmup (map get-snapshots (file->lines jags-test))))
(define augur-trials (remove-warmup (map fix-timings (map get-snapshots (file->lines augur-test)))))

(define (get-xy trials)
  (map (λ (trial) (for/list ([tsa trial])
                    (list (first tsa)  (third tsa))))
       trials))


;; (define (mean-time trials)
;;   (define (rec trials)
;;     (if (ormap empty? trials)
;;         '()
;;         (cons (let ([c (map car trials)])
;;                 (list (mean (map first c)) (mean (map second c)) ))
;;               (rec (map cdr trials)))))
;;    (rec trials))

;; (define rkt-mean-xy (mean-time (get-xy rkt-trials)))
;; (define jags-mean-xy (mean-time (get-xy jags-trials)))
;; (define augur-mean-xy (mean-time (get-xy augur-trials)))

(define (trial-plot runner trials pts lcolor lstyle icolor istyle legend pstyle)
  (define (mean-time trials)
    (define (rec trials)
      (if (ormap empty? trials)
          '()
          (cons (let ([c (map car trials)])
                  (cons (mean (map first c)) (map (λ (tsa) (cons (third tsa) (second tsa))) c) ))
                (rec (map cdr trials)))))
    (make-hash (rec trials)))
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
    #:color lcolor #:sym pstyle)

   (lines
    (sort (for/list ([(k v) tsa-map])
            (list k (mean (map car v))))
          (λ (v1 v2) (< (car v1) (car v2))))
    #:color lcolor #:style lstyle
    #:width 0.7
    ;; #:label legend
    )
   ))


(parameterize
    ([plot-font-face "Linux Libertine O"]
     [plot-x-ticks (linear-ticks #:divisors '(5) #:base 10 #:number 2)]
     [plot-y-ticks (linear-ticks #:divisors '(10) #:base 10 #:number 2)]
     [plot-y-far-axis? #f]
     [plot-x-far-axis? #f]
     [plot-legend-box-alpha 0])
  (plot-file
   (append
    (trial-plot "rkt"
                rkt-trials '()
                (make-object color% 0 73 73) 'solid
                (make-object color% 0 146 146) 'solid
                "LLVM-backend" 'triangle)
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
    ;; (list (tick-grid))
    )
   ;; (list (lines rkt-mean-xy #:color (make-object color% 0 73 73) #:label "Hakaru")
   ;;       (lines augur-mean-xy #:color (make-object color% 146 0 0) #:label "AugurV2")
   ;;       (lines jags-mean-xy #:color (make-object color% 146 0 0) #:label "JAGS")
   ;;       (tick-grid))
   "NaiveBayesGibbs-Likelihood.pdf"
   #:y-min -21800000
   #:y-max -21500000
   #:x-max 400
   #:height 300
   #:width 400
   #:y-label "Log likelihood"
   #:x-label "Time in seconds"

   #:legend-anchor 'right
   ))

#;(begin (define rkt-sta (run->sweep-time.accuracy rkt-trials))
         (define augur-sta (run->sweep-time.accuracy augur-trials))
         ;; (define hs-sta (run->sweep-time.accuracy hs-trials))
         ;; (define jags-sta (run->sweep-time.accuracy jags-trials))
         (define rkt-mta (sort (sweep-time.accuracy->mean$time.accuracy rkt-sta)
                               (λ (v1 v2) (< (car v1) (car v2)))))
         (define augur-mta (sort (sweep-time.accuracy->mean$time.accuracy augur-sta)
                                 (λ (v1 v2) (< (car v1) (car v2)))))
         ;; (define jags-mta (sort (sweep-time.accuracy->mean$time.accuracy jags-sta)
         ;;                        (λ (v1 v2) (< (car v1) (car v2)))))
         (pretty-display rkt-mta)
         (pretty-display augur-mta)

         (parameterize
             (;; [plot-x-transform log-transform]
              )
           (plot-file (list
                       (lines rkt-mta #:color (make-object color% 0 73 73)  #:label "hakrit" )
                       (lines augur-mta #:color (make-object color% 146 0 0)  #:label "augur")
                       ;; (lines jags-mta #:color (make-object color% 146 0 0)  #:label "jags" )
                       ;; (points jags-mta #:size 6 #:color (make-object color% 146 0 0) #:sym 'diamond)
                       ;; (points rkt-mta #:size 6 #:color (make-object color% 0 73 73) #:sym 'triangle)
                       ;; (lines (first hk-points) #:color 5 #:label "haskell")
                       )
                      "nb-plot.pdf"

                      #:y-min 0.9
                      #:y-max 0.4
                      #:legend-anchor 'bottom-right
                      #:x-label "seconds"
                      #:y-label "accuracy"
                      #:title "NaiveBayesGibbs"))

         )
