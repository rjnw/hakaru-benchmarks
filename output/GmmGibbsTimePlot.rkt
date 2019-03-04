#lang racket
(require plot
         racket/draw
         "plot-tsa.rkt"
         math/statistics)


(define (time-accuracy al)
  (map (λ (tr) (map (λ (tsa) (list (first tsa) (third tsa))) tr)) al))

(define (parse filename)
  (define trials (file->lines filename))
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
      (cons tim sweep)))
  (map (compose time-sweep-accuracy get-snapshots) trials))

(define (sweep-times trials)
  (define sweep-time (make-hash))
  (for ([trial trials])
    (for ([sweep trial])
      (hash-set! sweep-time (cdr sweep) (cons (car sweep) (hash-ref sweep-time (cdr sweep) '())))))
  (for/hash ([(sweep times) (in-hash sweep-time)])
    (values sweep (mean times))))

(define no-runtime-opt (sweep-times (parse "./GmmGibbs/rkt-sham/no-opt/25-5000")))
(define with-runtime-opt (sweep-times (parse "./GmmGibbs/rkt-sham/opt/25-5000")))

(plot (list (lines
             (sort (for/list ([(k v) no-runtime-opt])
                     (list k v))
                   (λ (v1 v2) (< (car v1) (car v2)))))
            (lines
             (sort (for/list ([(k v) with-runtime-opt])
                     (list k v))
                   (λ (v1 v2) (< (car v1) (car v2)))))
            (points (for/list ([(k v) no-runtime-opt])
                      (list k v)))
            (points (for/list ([(k v) with-runtime-opt])
                     (list k v)))))


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
     #:program "GmmGibbsTimePlot"
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
