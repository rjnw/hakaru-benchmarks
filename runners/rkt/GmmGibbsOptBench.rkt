#lang racket

(require sham
         hakrit
         racket/cmdline
         ffi/unsafe
         math/statistics
         racket/runtime-path
         "utils.rkt"
         "discrete.rkt")


(define testname "GmmGibbsB")
(define pair-array-regex "^\\(\\[(.*)\\],\\[(.*)\\]\\)$")

(define (run-test classes points)
  (define init-time (get-time))
  (printf "c, ~a, p: ~a\n" classes points)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define empty-info '(() () () () () ()))
  (define full-info
    `(()
      ((array-info . ((size . ,classes)
                      ;; (elem-info . ((prob-info . ((constant . 1.0)))))
                      ))
       ;; (attrs . (constant))
       )
      ((array-info
        . ((size . ,points)
           (elem-info
            . ((nat-info
                . ((value-range . (0 . ,(- classes 1))))))))))
      ((array-info . ((size . ,points)))
       ;; (attrs . (constant))
       ;; (value . ,(car input))
       )
      ((nat-info . ((value-range . (0 . ,(- points 1))))))))


  (define infile  (build-path input-dir testname (format "~a-~a" classes points)))
  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" classes points)))


  (define module-env (compile-file srcfile full-info))

  (define jit-val (curry rkt->jit module-env))

  ;; (jit-dump-module module-env)
  ;; (optimize-module module-env #:opt-level 3)
  ;; (initialize-jit! module-env #:opt-level 3)

  (define init-rng (time (jit-get-function 'init-rng module-env)))
  (define prog (jit-get-function 'prog module-env))
  (init-rng)
  (elasp-time init-time))

(module+ main ;;args
  (define (ms l) (define mn (mean l))
    (cons (mean l) (/ (stddev l) (sqrt (length l)))))
  (define s (for/list ([i (in-range 100)]) (run-test 50 10000)))
  (pretty-display (ms s))
  )
