#lang racket
(require plot plot/private/common/types)
(provide (all-defined-out))

(define (merge-legends l1 l2)
  (define h (make-hash))
  (define (process l)
    (cond [(list? l) (for-each process l)]
          [(legend-entry? l)
           (match-define (legend-entry label draw-proc) l)
           (hash-update! h label
             (lambda (draw-procs) (cons draw-proc draw-procs))
             (lambda () empty))]))
  (process l1)
  (process l2)
  (define (finalize entry)
    (define label (car entry))
    (define draw-procs (reverse (cdr entry)))
    (legend-entry label
      (lambda (plot-device x-size y-size)
        (for ([draw-proc draw-procs])
          (draw-proc plot-device x-size y-size)))))
  (map finalize (hash->list h)))

(define (merge-renderer2d-legends rend1 rend2)
  (match-define (renderer2d _  _  _  proc1) rend1)
  (match-define (renderer2d br bf tf proc2) rend2)
  (cond
   [(not proc1) rend2]
   [(not proc2) rend1]
   [else (renderer2d br bf tf
           (lambda (area) (merge-legends (proc1 area) (proc2 area))))]))
