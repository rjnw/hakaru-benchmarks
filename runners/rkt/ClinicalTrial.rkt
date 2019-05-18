#lang racket

(require sham
         hakrit
         disassemble
         racket/cmdline
         racket/runtime-path
         "gmm-utils.rkt")

(define testname "ClinicalTrial")

(define (run-test n)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define xfile  (build-path input-dir testname (number->string n)))
  (define outfile (build-path output-dir testname "rkt" (number->string n)))
  (define ctinfo
    (list (list `(natinfo . ((constant . ,n))))
          (list `(pairinfo . ((ainfo . ((arrayinfo . ((size . ,n)))))
                              (binfo . ((arrayinfo . ((size . ,n))))))))))

  (define module-env (compile-file srcfile))
  (define prog (get-prog module-env))

  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

  (define (tobool str)
    (match str
      ["True" 1]
      ["False" 0]))
  (define total-wrong 0)
  (define total 0)
  (define (run-single str out-port)
    (define m1 (regexp-match "\\(\\[(.*)\\],\\[(.*)\\]\\),(.*)\\)" str))
    (when (< (length m1) 4)
      (error "matching line from input"))
    (define a (map tobool (regexp-split "," (second m1))))
    (define b (map tobool (regexp-split "," (third m1))))
    (define i (tobool (fourth m1)))
    ;(printf "a: ~a, b: ~a, i: ~a\n" a b i)
    (define ca (sized-nat-array a))
    (define cb (sized-nat-array b))
    (define p (cons-array-pair ca cb))

    (define before-time (get-time))
    (define outi (prog n p))
    (define after-time (get-time))
    (fprintf out-port "~a ~a [~a]\t\n" (~r (- after-time before-time) #:precision '(= 3)) 1 outi)
    (printf "time: ~a\n" (- after-time before-time))
    (unless (equal? outi i) (set! total-wrong (+ total-wrong 1)))
    (set! total (+ total 1))
    outi)

  (time (call-with-input-file xfile
     (λ (xf-port)
       (call-with-output-file outfile #:exists 'replace
         (λ (out-port)
           (for ([line (in-lines xf-port)])
             (run-single line out-port))))))))

(module+ main
  (run-test (command-line #:args (n) (string->number n))))

(module+ test
  (time (run-test 10)))
;  (run-test 100)
;  (run-test 1000))
