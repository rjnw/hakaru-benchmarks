#lang racket
(require ffi/unsafe
         racket/runtime-path)


(provide get-ts
         diff-ts
         hksrc-dir
         input-dir
         gibbs-timer
         gibbs-sweep
         output-dir)


(define-runtime-path hksrc-dir "../../testcode/hkrkt/")
(define-runtime-path input-dir "../../input/")
(define-runtime-path output-dir "../../output/")


(define-cstruct _timespec
  ([tv_sec _slong]
   [tv_nsec _long]))

;;call ts before and after and then use diff,
;; we can make ts a pointer and cast it later in diff-ts to do marshalling
;; later but don't know how much that would gain us
(define get-ts
  (get-ffi-obj "clock_gettime" #f (_fun (clockid : _int = 2) (ts : (_ptr o _timespec)) -> (success : _int) ->
                                        (if (zero? success) ts (error "clock_gettime returned error code." success)))))

;; ts1 before, ts2 after => in microseconds
(define (diff-ts ts1 ts2)
  (- (+ (/ (timespec-tv_nsec ts2) 1000.0) (* (timespec-tv_sec ts2) 1000.0))
     (+ (/ (timespec-tv_nsec ts1) 1000.0) (* (timespec-tv_sec ts1) 1000.0))))


(define (elasp-seconds from) 0);;TODO
;; update: Nat -> Nat
;; state: vector
(define (gibbs-sweep iter-count state-pos-set! update state)
  (define (loop i)
    (if (zero? i)
        state
        (begin
          (state-pos-set! state (- i 1) (update (- i 1)))
          (loop (- i 1)))))
  (loop iter-count));(vector-length state)))


(define (gibbs-timer sweeper state printer
                     #:min-seconds [min-seconds 10]
                     #:step-seconds [step-seconds 0.5]
                     #:min-sweeps [min-sweeps 100]
                     #:step-sweeps [step-sweeps 10])
  (define start-time (get-ts))
  (define sweeps 0)
  (define (gibbs-trial)
    (define (step)
      (define time0 (get-ts))
      (define (step-sweep [sweeps step-sweeps])
        (if (zero? sweeps) (void)
            (begin (sweeper state)
                   (step-sweep (- sweeps 1)))))
      (define (step-second [seconds step-seconds])
        (define (step-done?) (> (elasp-seconds time0) step-seconds))
        (step-sweep) (set! sweeps (+ sweeps step-sweeps))
        (if (step-done?)
            (printer (elasp-seconds time0) sweeps state)
            (step-second (elasp-seconds time0))))
      (step-second))
    (define (trial-done?) (and (> sweeps min-sweeps) (> min-seconds (elasp-seconds start-time))))
    (unless (trial-done?) (gibbs-trial)))
  (void))



(module+ test
  (define before (get-ts))
  (for [[i (in-range 10000)]] (* i i))
  (define after (get-ts))
  (printf "total time: ~a\n" (diff-ts before after))
  (gibbs-sweep (λ (i) (printf "i: ~a\n" i) (* i i)) (vector 1 2 3 4 5)))
