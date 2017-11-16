#lang racket
(require ffi/unsafe
         racket/runtime-path)


(provide hksrc-dir
         input-dir
         get-time
         gibbs-timer
         gibbs-sweep
         output-dir)


(define-runtime-path hksrc-dir "../../testcode/hkrkt/")
(define-runtime-path input-dir "../../input/")
(define-runtime-path output-dir "../../output/")


(define _clock (get-ffi-obj "clock" #f (_fun -> _slong)))


(define (get-time)
  (/ (_clock) 1000.0))

(define (elasp-time from)
  (- (get-time) from))

;; update: state -> nat -> nat
;; state: array<nat>
(define (gibbs-sweep iter-count state-pos-set! update state)
  (define (loop i)
    (if (zero? i)
        state
        (let ([nz (update state (- i 1))])
          (state-pos-set! state (- i 1) nz)
          (loop (- i 1)))))
  (loop iter-count))


;; we are using microseconds as compared to haskell
;;; why because we can.
(define (gibbs-timer sweeper state printer
                     #:min-time [min-time 10000]
                     #:step-time [step-time 500]
                     #:min-sweeps [min-sweeps 100]
                     #:step-sweeps [step-sweeps 10])
  (define start-time (get-time))
  (define sweeps 0)
  (define (gibbs-trial)
    (define (step)
      (define time0 (get-time))
      (define (sweeper-step [sweeps step-sweeps])
        (if (zero? sweeps) (void)
            (begin (sweeper state)
                   (sweeper-step (- sweeps 1)))))
      (define (timer-step [tim step-time])
        (define (step-done?) (> (elasp-time time0) step-time))
        (sweeper-step)
        (set! sweeps (+ sweeps step-sweeps))
        (if (step-done?)
            (printer (elasp-time start-time) sweeps state)
            (timer-step (elasp-time time0))))
      (timer-step))
    (step)
    ;(printf "step done: sweeps: ~a, time: ~a\n" sweeps (elasp-time start-time))
    (define (trial-done?) (and (> sweeps min-sweeps) (> (elasp-time start-time) min-time)))
    (unless (trial-done?) (gibbs-trial)))
  (gibbs-trial)
  (void))



(module+ test
  (define before (get-time))
  (for [[i (in-range 10000)]] (* i i))
  (define after (get-time))
  (printf "total time: ~a\n" (- after  before))
  (gibbs-sweep (λ (i) (printf "i: ~a\n" i) (* i i)) (vector 1 2 3 4 5)))
