#lang racket

(require sham
         hakrit
         racket/cmdline
         racket/runtime-path
         "utils.rkt")

(define testname "ClinicalTrial")

(define (run-test n)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define xfile  (build-path input-dir testname (number->string n)))
  (define outfile (build-path output-dir testname "rkt" (number->string n)))
  (define ctinfo
    (list (list `(natinfo . ((constant . ,n))))
          (list `(pairinfo . ((ainfo . ((arrayinfo . ((size . ,n)))))
                              (binfo . ((arrayinfo . ((size . ,n))))))))))

  (define module-env (compile-file srcfile ctinfo))

  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)

  (define prog (jit-get-function 'prog module-env))

  (define make-pair-array-bool
    (jit-get-function (string->symbol (format "make$pair<array<~a.bool>*.array<~a.bool>*>" n n))
                      module-env))
  (define make-array-bool
    (jit-get-function (string->symbol (format "new-sized$array<~a.bool>" n))
                      module-env))
  (define set-index-array-bool
    (jit-get-function (string->symbol (format "set-index!$array<~a.bool>" n))
                      module-env))

  (define tbool (jit-get-racket-type 'bool module-env))

  (define (make-array lst)
    (define arr (make-array-bool))
    (for ([v lst]
          [i (in-range (length lst))])
      (set-index-array-bool arr i v))
    arr)

  (define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

  (define (tobool str)
    (match str
      ["True" 1]
      ["False" 0]))
  (define total-wrong 0)
  (define (run-single str out-port)
    (define m1 (regexp-match "\\(\\[(.*)\\],\\[(.*)\\]\\),(.*)\\)" str))
    (when (< (length m1) 4)
      (error "matching line from input"))
    (define a (map tobool (regexp-split "," (second m1))))
    (define b (map tobool (regexp-split "," (third m1))))
    (define i (tobool (fourth m1)))
    ;(printf "a: ~a, b: ~a, i: ~a\n" a b i)
    (define ca (make-array a))
    (define cb (make-array b))
    (define p (make-pair-array-bool ca cb))

    (define before-time (get-ts))
    (define outi (prog n p))
    (define after-time (get-ts))
    (fprintf out-port "~a ~a [~a]\t\n" (diff-ts before-time after-time) 1 outi)
    (unless (equal? outi i) (set! total-wrong (+ total-wrong 1)))
    outi)

  (call-with-input-file xfile
    (λ (xf-port)
      (call-with-output-file outfile #:exists 'replace
        (λ (out-port)
          (for ([line (in-lines xf-port)])
            (run-single line out-port))))))
  (printf "total-wrong: ~a\n" total-wrong))

(module+ main
  (run-test (command-line #:args (n) (string->number n))))

(module+ test
  (run-test 1000))
;  (run-test 100)
;  (run-test 1000))
