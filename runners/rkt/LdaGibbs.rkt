#lang racket
(require hakrit)

(require sham
         hakrit
         ffi/unsafe
         racket/cmdline
         racket/runtime-path
         disassemble
         "discrete.rkt"
         "utils.rkt")

(define testname "LdaGibbs")

(define (run-test)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define nbinfo (list (list) (list) (list) (list) (list) (list) (list) (list)))

  (define wordsfile  (build-path input-dir "news" "words"))
  (define docsfile   (build-path input-dir "news" "docs"))
  (define topicsfile   (build-path input-dir "news" "topics"))


  (define outfile (build-path output-dir testname "rkt" "out"))

  (define module-env (compile-file srcfile nbinfo))
  ;(jit-dump-module module-env)
  (jit-verify-module module-env)
  (initialize-jit! module-env)
  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)


  (define rk-words (map string->number (file->lines wordsfile)))
  (define rk-docs (map string->number (file->lines docsfile)))
  (define rk-topics (map string->number (file->lines topicsfile)))

  (define make-prob-array (jit-get-function (string->symbol (format "make$array<prob>")) module-env))
  (define set-index-prob-array (jit-get-function (string->symbol (format "set-index!$array<prob>")) module-env))

  (define make-nat-array (jit-get-function (string->symbol (format "make$array<nat>")) module-env))
  (define set-index-nat-array (jit-get-function (string->symbol (format "set-index!$array<nat>")) module-env))
  (define get-index-nat-array (jit-get-function (string->symbol (format "get-index$array<nat>")) module-env))

  (define make-real-array (jit-get-function (string->symbol (format "make$array<real>")) module-env))
  (define set-index-real-array (jit-get-function (string->symbol (format "set-index!$array<real>" )) module-env))

  (define prog (jit-get-function 'prog module-env))

  (define num-docs (add1 (last rk-docs)))
  (define num-words (add1 (argmax identity rk-words)))
  (define num-topics (add1 (argmax identity rk-topics)))

  (define topicPrior (make-prob-array num-topics
                                      (list->cblock (build-list num-topics (const 0.0)) _double)))
  (define wordPrior (make-prob-array num-words
                                     (list->cblock (build-list num-words (const 0.0)) _double)))

  (define words (make-nat-array (length rk-words) (list->cblock rk-words _uint64)))
  (define docs (make-nat-array (length rk-docs) (list->cblock rk-docs _uint64)))

  (define (update z docUpdate)
    (prog topicPrior wordPrior num-docs words docs z docUpdate))

  (define zs (replicate-uniform-discrete (length rk-words) 0 (- num-topics 1)))
  (define z (make-nat-array (length rk-words) (list->cblock zs _uint64)))

  (define (run-single out-port)
    (gibbs-timer (curry gibbs-sweep num-topics set-index-nat-array update)
                 z
                 (λ (tim sweeps state)
                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- num-topics 1))])
                     (fprintf out-port "~a, " (get-index-nat-array state i)))
                   (fprintf out-port "~a]\t" (get-index-nat-array state (- num-topics 1)))))
    (printf "final state: ~a, \n\tactual state: ~a\n"
            (for/list ([i (in-range num-topics)])
              (get-index-nat-array z i))
            rk-topics))


  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (run-single out-port))))




(run-test)
