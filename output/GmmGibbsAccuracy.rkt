#lang racket
(require plot
         racket/draw
         "plot-tsa.rkt"
         math/statistics)


(define (time-accuracy al)
  (map (λ (tr) (map (λ (tsa) (list (first tsa) (third tsa))) tr)) al))

(define (plot-accuracy classes pts)
  (define (time-as al (i 0.01))
    (define j (/ 1 i))
    (define (mean-accuracy al)
      (if (ormap empty? al)
          '()
          (cons (let ([c (map car al)])
                  (cons (mean (map first c)) (map (λ (tsa) (cons (third tsa) (second tsa))) c) ))
                (mean-accuracy (map cdr al)))))
    ;; (define time-map (make-hash (mean-accuracy al)))
    (define time-map (make-hash))
    (map (λ (tr)
           (for ([sw tr])
             (match-define (list t s a) sw)
             (define tn (/ (round (* t j)) j))
             (hash-set! time-map tn (cons (cons a s) (hash-ref time-map tn '())))))
         al)
    time-map
    (make-hash (mean-accuracy al)))

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
      (map (λ (shot) (list (- (first shot) min-time) (second shot) (third shot))) trial)))

  (define (line-intr runner lcolor lstyle icolor istyle legend pstyle  (i 1))
    (define pr (remove-warmup (parse runner)))
    (define sta (run->sweep-time.accuracy pr))
    ;; (pretty-display sta)
    (define smta (sweep-time.accuracy->sweep-mean$time.accuracy sta))
    ;; (pretty-display smta)
    (define tsa  (time-as pr))
    (list
     (lines-interval
      (sort (for/list ([(k v) tsa])
              (list k (+ (mean (map car v))
                         (/ (stddev (map car v))
                            (sqrt (length (map car v)))))))
            (λ (v1 v2) (< (car v1) (car v2))))
      (sort (for/list ([(k v) tsa])
              (list k  (- (mean (map car v))
                          (/ (stddev (map car v))
                             (sqrt (length (map car v)))))))
            (λ (v1 v2) (< (car v1) (car v2))))
      #:color icolor #:style istyle
      #:line1-style 'transparent #:line2-style 'transparent
      #:alpha 0.3)

     (points
      (for/list ([(s ta) smta]
                 #:when (zero? (modulo s 10)))
        ta)
      #:size 4 #:color lcolor #:sym pstyle)
     ;; (points
     ;;  (apply append
     ;;         (for/list ([trial pr])
     ;;           (for/list ([p trial])
     ;;             (list (car p) (caddr p)))))
     ;;  #:size 1 #:alpha 0.1 #:line-width 1
     ;;  #:color color #:label (string-append runner "-dots"))

     (lines
      (sort (for/list ([(k v) tsa])
              (list k (mean (map car v))))
            (λ (v1 v2) (< (car v1) (car v2))))
      #:color lcolor #:style lstyle
      #:width 1
      #:label legend)
     ))
  (plot-file
   (append
    ;; http://www.somersault1824.com/wp-content/uploads/2015/02/color-blindness-palette.png
    ;; line-color line-style interval-color style legend line-points
    (line-intr "rkt"
               (make-object color% 0 73 73) 'solid
               (make-object color% 0 146 146) 'solid
               "Hakaru LLVM-backend" 'triangle)
    (line-intr "hk"
               (make-object color% 73 0 146) 'dot-dash
               (make-object color% 0 146 146) 'solid
               "Hakaru Haskell-backend" 'square)
    (line-intr "jags"
               (make-object color% 146 0 0) 'short-dash
               (make-object color% 146 73 0) 'solid
               "JAGS" 'diamond)
    (list (tick-grid)))
   (format "./mean/GmmGibbs~a-~a.pdf" classes pts)
   #:y-max 100
   #:y-min 0
   #:x-max 90
   #:y-label "Accuracy in %" #:x-label "Time in seconds" #:legend-anchor 'top-right))

(module+ main
  (define-values (classes points)
    (command-line #:args (classes points)
                  (values (string->number classes)
                          (string->number points)))))

(module+ test
  ;; (plot-accuracy 9 1000)
  ;; (plot-accuracy 12 1000)
  ;; (plot-accuracy 15 1000)
  ;; (plot-accuracy 20 1000)
  ;; (plot-accuracy 25 10000)
  (plot-accuracy 50 10000)
  ;; (plot-accuracy 30 1000)
  )
