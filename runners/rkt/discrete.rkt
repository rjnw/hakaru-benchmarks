#lang racket
(require math)

(provide replicate-uniform-discrete
         discrete-sampler)

(define (replicate-uniform-discrete size start end)
  (define distf (discrete-dist (build-list (- end start) (λ (i) (+ start i)))))
  (build-list size (λ (i) (sample distf))))

(define (discrete-sampler start end)
  (define distf (discrete-dist (build-list (- end start) (λ (i) (+ start i)))))
  (λ () (sample distf)))
