#lang racket
(require math/statistics
         plot)
(provide (all-defined-out))
;; snapshot = tsa = (list time sweep accuracy)
;; trial = (list snapshot)
;; run = (list trial)

(define tsa->t first)
(define tsa->s second)
(define tsa->a third)

;; (hash sweep (list accuracy))
(define (run->sweep-accuracy run)
  (define sweep-accuracy (make-hash))
  (define (add-accuracy sweep acc)
    (hash-set! sweep-accuracy sweep (cons acc (hash-ref sweep-accuracy sweep '()))))
  (for ([trial run])
    (for ([snapshot trial])
      (add-accuracy (tsa->s snapshot) (tsa->a snapshot))))
  sweep-accuracy)

;; (hash sweep (list (cons time accuracy)))
(define (run->sweep-time.accuracy run)
  (define m (make-hash))
  (define (add-ta s t a)
    (hash-set! m s (cons (list t a) (hash-ref m s '()))))
  (for ([trial run])
    (for ([snapshot trial])
      (add-ta (tsa->s snapshot) (tsa->t snapshot) (tsa->a snapshot))))
  m)

(define (sweep-time.accuracy->mean$time.accuracy sta)
  (for/list ([(s ta) (in-hash sta)])
    (list (mean (map car ta)) (mean (map second ta)))))

(define (sweep-time.accuracy->mean$sweep.accuracy sta)
  (for/list ([(s ta)  sta])
    (list s (mean (map second ta)))))

(define (sweep-time.accuracy->sweep-mean$time.accuracy sta)
  (for/hash ([(s ta)  sta])
    (values s (list (mean (map car ta)) (mean (map second ta))))))

(define ((tsa->mean-line tsa) color legend-title)
  (lines
   (sort (for/list ([(k v) tsa])
           (list k (mean (map car v))))
         (λ (v1 v2) (< (car v1) (car v2))))
   #:color color
   #:width 1
   #:label  legend-title))
