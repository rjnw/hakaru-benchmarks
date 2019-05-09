#lang racket

(require racket/cmdline
         racket/runtime-path)
(require racket/draw
         math/statistics
         plot)
(define source-dir "../testcode/hkrkt/")

(define topics 50)

(define (trial->tsa trial)
  (define (get-snapshots st)
    (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
    (define f  string->number)
    (map (λ (s) (match-define (list tim sweep state) s)
            (list (string->number tim)
                  (inexact->exact (f sweep))
                  (map f (regexp-match* #px"-?\\d+\\.?\\d*" state))))
         snapshots))
  (define sshots (get-snapshots trial))
  (for/list ([shot sshots])
    (define sweep (second shot))
    (define tim (first shot))
    (define acc (first (third shot)))
    ;; (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
    (list tim sweep acc)))

(define trials->tsa (curry map trial->tsa))

(define (parse runner)
  (trials->tsa (file->lines (build-path "./accuracies/LdaGibbs/" runner))))
(define (fix-sweeps trials)
  (define-values (ntrials st)
    (for/fold ([ntrials '()]
               [nsweeps 1])
              ([tsa trials])
      (match-define (list tim sweep acc) tsa)
      (values (cons (list tim nsweeps acc) ntrials) (add1 nsweeps))))
  (reverse ntrials))


(define (get-xy tsa)
  (for/list ([t tsa])
    (list (first t) (third t))))

;; (define rkt-xy (get-xy rkt-trials))
;; (define augur-xy (get-xy augur-trials))
(define (mean-time trials)
    (define (rec trials)
      (if (ormap empty? trials)
          '()
          (cons (let ([c (map car trials)])
                  (cons (mean (map first c)) (map (λ (tsa) (cons (third tsa) (second tsa))) c) ))
                (rec (map cdr trials)))))
    (make-hash (rec trials)))

(define (remove-warmup tsa)
  (for/list ([trial tsa])
    (define min-time (first (first trial)))
    (map (λ (shot) (list (- (first shot) min-time) (second shot) (third shot))) trial)))

(define (trial-plot runner trials lcolor lstyle icolor istyle  pstyle  (i 1) (point-size 6))
  (define tsa-map (mean-time trials))
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
    #:alpha 0.3)
   (lines
    (sort (for/list ([(k v) tsa-map])
            (list k (mean (map car v))))
          (λ (v1 v2) (< (car v1) (car v2))))
    #:color lcolor #:style lstyle
    #:width 0.7
    #:label runner)
   (if (equal? runner "AugurV2")
       (points
        (for/list ([(k v) tsa-map]
                   #:when (and (not (zero? (first (map cdr v))))
                               (zero? (modulo (first (map cdr v)) 10))))
          (list k (mean (map car v))))
        #:size point-size #:color lcolor #:sym pstyle)
       (points
        (for/list ([(k v) tsa-map]
                   #:when (and (not (zero? (sub1 (first (map cdr v)))))
                               (member (first (map cdr v)) '(1 37 73))))
          (list k (mean (map car v))))
        #:size point-size #:color lcolor #:sym pstyle))
   ;; (points
   ;;  trial
   ;;  #:size point-size #:alpha 0.1 #:line-width 1
   ;;  #:color lcolor #:sym pstyle)

   ;; (lines
   ;;  (get-xy trials)
   ;;  #:color lcolor #:style lstyle
   ;;  #:width 1
   ;;  #:label runner)
   )
  )


(define (plot-likelihood topics output-file)
  (define rkt-orig   (parse (format "kos/~a-~a"  "rkt" topics)))
  (define rkt-trials (map fix-sweeps rkt-orig))
  (define augur-orig (parse (format "kos/~a-~a" "augur" topics)))
  (define augur-trials (filter (compose not empty?) augur-orig))

  (parameterize
      (
       [plot-font-size 6]
       [plot-font-face "Linux Libertine O"]
       [plot-legend-box-alpha 1]
       ;; [plot-x-ticks (linear-ticks #:divisors '(5) #:base 10 #:number 5)]
       ;; [plot-y-ticks (linear-ticks #:divisors '(10) #:base 10 #:number 2)]
       [plot-y-far-axis? #f]
       [plot-x-far-axis? #f]
       [plot-legend-box-alpha 1])
      (plot-file
       (list
        (trial-plot "Hakaru" (remove-warmup rkt-trials)
                    (make-object color% 0 73 73) 'solid
                    (make-object color% 0 146 146) 'solid
                    'triangle)

        (trial-plot "AugurV2" (remove-warmup augur-trials)
                    (make-object color% 146 73 0) 'solid
                    (make-object color% 0 0 0) 'solid
                    'bullet))

       ;; (format "../../ppaml/writing/pipeline/ldalikelihood-~a.pdf" topics)
       output-file
       #:legend-anchor 'bottom-right
       ;; topics 100
       ;; #:y-min -4700000
       ;; #:y-max -4500000
       ;; #:x-max 800

       ;; topics 50
       ;; #:y-max -4200000
       ;; #:y-min -4400000
       ;; #:x-max 800

       #:y-max (y-min)
       #:y-min (y-max)
       #:x-min (x-min)
       #:x-max (x-max)
       #:width (width)
       #:height (height)

       #:y-label "Log likelihood"
       #:x-label "Time in seconds")))

(define y-min (make-parameter #f))
(define y-max (make-parameter #f))
(define x-max (make-parameter #f))
(define x-min (make-parameter #f))
(define width (make-parameter (plot-width)))
(define height (make-parameter (plot-height)))

(module+ main
  (define-values (topics output-file)
    (command-line
     #:program "LdaLikelihoodPlot"
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
     #:args (topics output-file)
     (values topics output-file)))
  (plot-likelihood topics output-file))

(module+ test
  ;; topics 100
  (parameterize ([y-min -4700000]
                 [y-max -4500000]
                 [x-max 800])
    (plot-likelihood 100 "../../ppaml/writing/pipeline/ldalikelihood-100.pdf"))

  (parameterize ([y-min -4200000]
                 [y-max -4400000]
                 [x-max 800])
    (plot-likelihood 50 "../../ppaml/writing/pipeline/ldalikelihood-50.pdf")))
