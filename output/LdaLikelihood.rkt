#lang racket

(require racket/cmdline
         racket/runtime-path)
(require racket/draw
         math/statistics
         plot)
(define source-dir "../testcode/hkrkt/")

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

(define topics 50)
(define rkt-orig   (parse (format "kos/~a-~a"  "rkt" topics)))
(define rkt-trials (map fix-sweeps rkt-orig))
;; (error 'stop)
(define augur-orig (parse (format "kos/~a-~a" "augur" topics)))
(define augur-trials (filter (compose not empty?) augur-orig))
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
   ;; (points
   ;;  (for/list ([(s ta) smta]
   ;;             #:when (zero? (modulo s 10)))
   ;;    ta)
   ;;  #:size point-size #:color lcolor #:sym pstyle)
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


(plot-file
 (list
  (trial-plot "Hakaru" rkt-trials
            (make-object color% 0 73 73) 'solid
            (make-object color% 0 146 146) 'solid
   'triangle)

  (trial-plot "AugurV2" augur-trials
            (make-object color% 73 0 146) 'solid
            (make-object color% 0 146 146) 'solid
            "AugurV2" 'square)
  (tick-grid)
  )

 (format "ldalikelihood-~a.pdf" topics)
 #:legend-anchor 'bottom-right
 ;; #:y-min -4700000
 ;; #:y-max -4500000
 ;; #:x-max 800

 ;; topics 50
 #:y-max -4200000
 #:y-min -4400000

 #:x-max 800


 #:y-label "Log likelihood"
 #:x-label "Time in seconds"
 )
