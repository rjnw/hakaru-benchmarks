#lang racket

(require sham
         hakrit
         racket/cmdline
         racket/runtime-path
         "utils.rkt")

(define testname "testname")

(define (run-test . args)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define input-files  (build-path input-dir testname <args>))
  (define outfile (build-path output-dir testname "rkt" <args>))
  (define info ...)

  (define module-env (compile-file srcfile info))

  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)

  (define prog (jit-get-function 'prog module-env))

  (define (run-single str out-port))

  (call-with-input-file xfile
    (λ (xf-port)
      (call-with-output-file outfile #:exists 'replace
        (λ (out-port)
          (for ([line (in-lines xf-port)])
            (run-single line out-port)))))))


(module+ main ;;args
  (run-test (command-line #:args (n) (string->number n))))

(module+ test
  (run-test args))
