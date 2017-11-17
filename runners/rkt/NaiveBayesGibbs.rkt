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

(define testname "NaiveBayesGibbs")

(define (run-test)
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define nbinfo (list (list) (list) (list) (list) (list) (list)))

  (define wordsfile  (build-path input-dir "news" "words"))
  (define docsfile   (build-path input-dir "news" "docs"))
  (define topicsfile   (build-path input-dir "news" "topics"))

  (define rk-words (map string->number (file->lines wordsfile)))
  (define rk-docs (map string->number (file->lines docsfile)))
  (define rk-topics (map string->number (file->lines topicsfile)))


  (define word-size (length rk-words))
  (define docs-size (length rk-docs))
  (define topics-size (length rk-topics))
  (printf "word-size: ~a, docs-size: ~a, topics-size: ~a\n"
          word-size docs-size topics-size)

  (define num-docs (add1 (last rk-docs)))
  (define num-words (add1 (argmax identity rk-words)))
  (define num-topics (add1 (argmax identity rk-topics)))
  (printf "num-docs: ~a, num-words: ~a, num-topics: ~a\n" num-docs num-words num-topics)


  (define outfile (build-path output-dir testname "rkt" "out"))

  ;; (define nbinfo
  ;;   (list
  ;;    (list `(arrayinfo . ((size . ,num-topics)
  ;;                         (typeinfo . ((probinfo . ((constant . 0)))))
  ;;                         (constant . #t)))
  ;;          `(fninfo . (remove)))
  ;;    (list `(arrayinfo . ((size . ,num-words)
  ;;                         (typeinfo . ((probinfo . ((constant . 0)))))
  ;;                         (constant . #t)))
  ;;          `(fninfo . (remove)))
  ;;    (list `(arrayinfo . ((size . ,num-docs)
  ;;                         (typeinfo . ((probinfo . ((constant . 0)))))
  ;;                         (constant . #t))))
  ;;    (list `(arrayinfo . ((size . ,word-size))))
  ;;    (list `(arrayinfo . ((size . ,docs-size))))
  ;;    (list `(natinfo . ((valuerange . (0 . ,(- num-docs 1))))))))

  (define module-env (compile-file srcfile nbinfo))
  ;(jit-write-module module-env "nb.ll")
  ;(jit-dump-module module-env)
  ;(jit-verify-module module-env)
  (optimize-module module-env #:opt-level 3)
  (initialize-jit! module-env)
  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)

  (define make-prob-array
    (jit-get-function (string->symbol (format "make$array<prob>")) module-env))
  (define new-sized-prob-array
    (jit-get-function (string->symbol (format "new-sized$array<prob>")) module-env))
  (define set-index-prob-array
    (jit-get-function (string->symbol (format "set-index!$array<prob>")) module-env))

  (define make-nat-array
    (jit-get-function (string->symbol (format "make$array<nat>")) module-env))
  (define new-sized-nat-array
    (jit-get-function (string->symbol (format "new-sized$array<nat>")) module-env))
  (define set-index-nat-array
    (jit-get-function (string->symbol (format "set-index!$array<nat>")) module-env))
  (define get-index-nat-array
    (jit-get-function (string->symbol (format "get-index$array<nat>")) module-env))

  (define make-real-array
    (jit-get-function (string->symbol (format "make$array<real>")) module-env))
  (define new-sized-real-array
    (jit-get-function (string->symbol (format "new-sized$array<real>")) module-env))
  (define set-index-real-array
    (jit-get-function (string->symbol (format "set-index!$array<real>" )) module-env))

  (define prog (jit-get-function 'prog module-env))
;  (disassemble-ffi-function (jit-get-function-ptr 'prog module-env) #:size 1000)


  (define topicPrior (new-sized-prob-array num-topics))
  (for ([i (in-range num-topics)])
    (set-index-prob-array topicPrior i 0.0))

  ;(make-prob-array num-topics (list->cblock (build-list num-topics (const 0.0)) _double)))
  (define wordPrior (new-sized-prob-array num-words))
  (for [(i (in-range num-words))]
    (set-index-prob-array wordPrior i 0.0))
    ;(make-prob-array num-words (list->cblock (build-list num-words (const 0.0)) _double)))

  (define words (new-sized-nat-array word-size))
  ;(make-nat-array (length rk-words) (list->cblock rk-words _uint64)))
  (for ([i (in-range word-size)]
        [v rk-words])
    (set-index-nat-array words i v))
  (define docs (new-sized-nat-array docs-size))
  (for ([i (in-range docs-size)]
        [v rk-docs])
    (set-index-nat-array docs i v));(make-nat-array (length rk-docs) (list->cblock rk-docs _uint64)))

  (define (update z docUpdate)
    (prog topicPrior wordPrior z words docs docUpdate))

  (define zs (replicate-uniform-discrete num-docs 0 (- num-topics 1)))
  (printf "~a\n" zs)
  (define z (make-nat-array num-docs (list->cblock zs _uint64)))
  (printf "done till here\n")
  ;  (prog z words docs 4)
  (define (run-single out-port)
    (gibbs-timer (curry gibbs-sweep num-docs set-index-nat-array update)
                 z
                 (λ (tim sweeps state)
                   (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) sweeps)
                   (for ([i (in-range (- num-docs 1))])
                     (fprintf out-port "~a, " (get-index-nat-array state i)))
                   (fprintf out-port "~a]\t" (get-index-nat-array state (- num-topics 1)))))
    (printf "final state: ~a, \n\tactual state: ~a\n"
            (for/list ([i (in-range num-topics)])
              (get-index-nat-array z i))
            rk-topics)))

(module+ test 
  (run-test))
(run-test)
