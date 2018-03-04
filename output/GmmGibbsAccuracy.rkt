#lang racket
(require plot
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
        (list tim sweep acc)))
    (map (compose time-sweep-accuracy get-snapshots) trials))

  (define (line-intr runner color (i 1))
    (define pr (parse runner))
    (define tsa (time-as pr))
    ;; (pretty-display pr)
    ;; (pretty-display tsa)
    ;; (pretty-display (for/list ([(k v) tsa])
    ;;                   (list k (mean (map car v)))))
    (list
     ;; (lines-interval
     ;;  (sort (for/list ([(k v) tsa])
     ;;          (list k (quantile 5/8 < (map car v))))
     ;;        (λ (v1 v2) (< (car v1) (car v2))))
     ;;  (sort (for/list ([(k v) tsa])
     ;;          (list k (quantile 3/8 < (map car v))))
     ;;        (λ (v1 v2) (< (car v1) (car v2))))

     ;;  #:color color
     ;;  #:line1-color color #:line2-color color
     ;;  #:line1-width 0 #:line2-width 0
     ;;  #:line1-style 'transparent #:line2-style 'transparent
     ;;  #:alpha 0.5)

     ;; (points
     ;;  (apply append
     ;;         (for/list ([trial pr])
     ;;           (for/list ([p trial])
     ;;             (list (car p) (caddr p)))))
     ;;  #:size 0 #:alpha 0.1 #:line-width 1
     ;;  #:color color #:label (string-append runner "-dots"))

     ;; (lines
     ;;  (sort (for/list ([(k v) tsa])
     ;;          (list k (median < (map car v))))
     ;;        (λ (v1 v2) (< (car v1) (car v2))))
     ;;  #:color color
     ;;  #:width 1
     ;;  #:label  (string-append runner "-median"))
     (lines
      (sort (for/list ([(k v) tsa])
              (list k (mean (map car v))))
            (λ (v1 v2) (< (car v1) (car v2))))
      #:color color
      #:width 1
      #:label  (string-append runner "-mean"))
     ))
  (plot-file
   (append
    (line-intr "rkt" 1)
    (line-intr "hk" 2)
    (line-intr "jags" 3)
    (list (tick-grid)))
   (format "./mean/GmmGibbs~a-~a.pdf" classes pts)

   #:y-max 1
   #:y-min 0
   #:x-max 1.5
   #:y-label "accuracy" #:x-label "time" #:legend-anchor 'bottom-right))

(module+ main
  (define-values (classes points)
    (command-line #:args (classes points)
                  (values (string->number classes)
                          (string->number points)))))

(module+ test
  (plot-accuracy 9 1000)
  (plot-accuracy 12 1000)
  (plot-accuracy 15 1000)
  (plot-accuracy 20 1000)
  (plot-accuracy 25 1000)
  (plot-accuracy 30 1000))
