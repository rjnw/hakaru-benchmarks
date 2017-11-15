#lang racket
(require ffi/unsafe
         racket/runtime-path)


(provide get-ts
         diff-ts
         hksrc-dir
         input-dir
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


(module+ test
  (define before (get-ts))
  (for [[i (in-range 10000)]] (* i i))
  (define after (get-ts))
  (printf "total time: ~a\n" (diff-ts before after)))
