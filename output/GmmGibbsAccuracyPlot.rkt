#lang racket
(require plot
         racket/draw
         "plot-tsa.rkt"
         math/statistics)


(define (time-accuracy al)
  (map (λ (tr) (map (λ (tsa) (list (first tsa) (third tsa))) tr)) al))

(define (plot-accuracy classes pts output-file)
  (define (mean-time trials)
    (define (rec trials)
      (if (ormap empty? trials)
          '()
          (cons (let ([c (map car trials)])
                  (cons (mean (map first c)) (map (λ (tsa) (cons (third tsa) (second tsa))) c) ))
                (rec (map cdr trials)))))
    (make-hash (rec trials)))

  (define (parse runner)
    (define accuracy-file (build-path "./accuracies/GmmGibbs/" (format "~a/~a-~a" runner classes pts)))
    (define trials (file->lines accuracy-file))
    (define (get-snapshots st)
      (define f (compose inexact->exact string->number))
      (map (λ (s) (match-define (list tim sweep state) s)
              (list (string->number tim)
                    (f sweep)
                    (map string->number (regexp-match* #px"\\d+\\.?\\d*" state))))
           (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr)))

    (define (time-sweep-accuracy snapshots)
      (for/list ([shot snapshots])
        (define sweep (second shot))
        (define tim (first shot))
        (define acc  (first (third shot)))
        ;; (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
        (list tim sweep (* 100 acc))))
    (map (compose time-sweep-accuracy get-snapshots) trials))

  (define (remove-warmup tsa)
    (for/list ([trial tsa])
      (define min-time (first (first trial)))
      ;; (printf "~a " min-time)
      (map (λ (shot) (list (- (first shot) min-time) (second shot) (third shot))) trial)))

  (define (trial-plot runner trials pts lcolor lstyle icolor istyle legend pstyle  (i 1) (point-size 3))
    (define sta^ (run->sweep-time.accuracy trials))
    (define smta (sweep-time.accuracy->sweep-mean$time.accuracy sta^))
    (define tsa-map (mean-time trials))
    ;; (pretty-print tsa-map)
    ;; (pretty-print sta^)
    ;; (pretty-print (map cdr
    ;;                    (sort (hash->list smta)
    ;;                          (λ (v1 v2) (< (car v1) (car v2))))))
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
      (for/list ([v sta]
                 #:when (if  (equal? runner "augur")
                            (zero? (modulo (sub1 (first v)) 200))
                            (if (equal? runner "stan")
                                 #f
                                (zero? (modulo (first v) 10)))))
        (cdr v))
      #:line-width 0.5
      #:size point-size #:color lcolor #:sym pstyle)

     (lines
      ;; (sort
      ;;  (map cdr
      ;;       (sort (hash->list smta)
      ;;             (λ (v1 v2) (< (car v1) (car v2)))))
      ;;  (λ (v1 v2) (< (car v1) (car v2))))
      (sort (for/list ([(k v) tsa-map])
              (list k (mean (map car v))))
            (λ (v1 v2) (< (car v1) (car v2))))
      #:color lcolor #:style lstyle
      #:width 0.7
      #:label legend
      )
     ))

  (define get-trial parse)
  (define (fix-timings trials)
    (define-values (ntrials t)
      (for/fold ([ntrials '()]
                 [t 0])
                ([tsa trials])
        (match-define (list tim sweep acc) tsa)
        (values (cons (list (+ tim t) sweep acc) ntrials)
                (+ tim t))))
    (reverse ntrials))
  ;; (define hk-trial (remove-warmup (get-trial "hk")))
  (define augur-trial (remove-warmup (get-trial "augur")))
  (define stan-trial (remove-warmup (get-trial "stan")))
  (define jags-trial (remove-warmup (get-trial "jags")))
  (define rkt-trial (remove-warmup  (get-trial "rkt")))
  (parameterize
      (
       ;; [plot-font-size 10]
       [plot-legend-box-alpha 1]
       [plot-x-ticks (linear-ticks #:divisors '(5) #:base 10 #:number 5)]
       [plot-y-ticks (linear-ticks #:divisors '(10) #:base 10 #:number 2)]
       [plot-y-far-axis? #f]
       [plot-x-far-axis? #f]
       [plot-legend-box-alpha 1])
    (plot-file
     (append
      ;; http://www.somersault1824.com/wp-content/uploads/2015/02/color-blindness-palette.png
      ;; line-color line-style interval-color style legend line-points
      ;; (trial-plot "hk"
      ;;             hk-trial '()
      ;;             (make-object color% 73 0 146) 'dot-dash
      ;;             (make-object color% 0 146 146) 'solid
      ;;             "Haskell-backend" 'square)

      (trial-plot "rkt"
                  rkt-trial '()
                  (make-object color% 0 73 73) 'solid
                  (make-object color% 0 146 146) 'solid
                  "Hakaru" 'triangle)
      (trial-plot "augur"
                  (map (curry filter (λ (tsa) (zero? (modulo (sub1 (second tsa)) 20)))) augur-trial)
                  '()
                  (make-object color% 146 73 0) 'solid
                  (make-object color% 0 0 0) 'solid
                  "AugurV2" 'bullet)
      (trial-plot "jags"
                  jags-trial
                  '()
                  (make-object color% 146 0 0) 'short-dash
                  (make-object color% 146 73 0) 'solid
                  "JAGS" 'diamond)
      (trial-plot "stan"
                  stan-trial
                  '()
                  (make-object color% 0 109 219) 'long-dash
                  (make-object color% 0 109 219) 'solid
                  "stan" 'diamond)
      ;; (list (tick-grid))
      )
     output-file
     ;; (format "../../ppaml/writing/pipeline/GmmGibbs~a-~a.pdf" classes pts)
     #:y-max ( y-min)
     #:y-min ( y-max)
     #:x-min ( x-min)
     #:x-max ( x-max)
     #:width ( width)
     #:height ( height)

     ;; 50-10000
     ;; #:y-max 45
     ;; #:y-min 15
     ;; #:x-max 30
     ;; #:width 300
     ;; #:height 300


     ;; 25-5000
     ;; #:y-max 60
     ;; #:y-min 30
     ;; #:x-max 10
     ;; #:width 300
     ;; #:height 300

     #:y-label "Accuracy in %" #:x-label "Time in seconds"
     #:legend-anchor 'bottom-right)))

;; full optimizations 294.1ms
;; no runtimeopts 485.0ms
;; no histogram 22000ms
;; no licm and loop fusion 11000ms
;; no loop fusion 400ms
(define y-min (make-parameter 30))
(define y-max (make-parameter 60))
(define x-max (make-parameter 20))
(define x-min (make-parameter 0))
(define width (make-parameter 500))
(define height (make-parameter 500))

(module+ main
  (define-values (classes points output-file)
    (command-line
     #:program "GmmGibbsAccuracyPlot"
     #:once-each
     ["--y-min" yn "Minimum value for y-axis"
                (y-min (string->number yn))]
     ["--y-max" yx "Maximum value for y-axis"
                (y-max (string->number yx))]
     ["--x-min" xn "Minimum value for x-axis"
                (x-min (string->number xn))]
     ["--x-max" xx "Maximum value for x-axis"
                (x-max (string->number xx))]
     ["--width" w "Width of the plot"
                (width (string->number w))]
     ["--height" h "Height of the plot"
                 (height (string->number h))]
     #:args (classes points output-file)
     (values (string->number classes) (string->number points) output-file)))
  (plot-accuracy classes points output-file)
  (pretty-print (list classes points output-file)))

;; racket GmmGibbsAccuracyPlot.rkt --x-max 10 --y-min 30 --y-max 60 --height 200 --width 400 25 5000 "./plot.pdf"

(module+ test
  ;; (plot-accuracy 6 10 "test.pdf")
  ;; (plot-accuracy 12 1000)
  ;; (plot-accuracy 15 1000 "gmm-15-1000-new.pdf")
  ;; (plot-accuracy 50 10000 "gmm-50-10000.pdf")
  ;; (plot-accuracy 25 1000 "gmm-25-1000-old.pdf")
  (plot-accuracy 25 5000 "gmm-25-5000-new.pdf")

  ;; (plot-accuracy 80 10000)
  ;; (plot-accuracy 100 10000)
  )
