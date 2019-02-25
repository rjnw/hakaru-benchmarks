#lang racket
(require hakrit)

(require sham
         hakrit
         math/statistics
         ffi/unsafe
         racket/cmdline
         racket/runtime-path
         racket/date
         disassemble
         "discrete.rkt"
         "utils.rkt")

(define testname "NaiveBayesGibbsB")

  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define newsd "news")
  (define wordsfile  (build-path input-dir newsd "words"))
  (define docsfile   (build-path input-dir newsd "docs"))
  (define topicsfile   (build-path input-dir newsd "topics"))

  (define rk-words (map string->number (file->lines wordsfile)))
  (define rk-docs (map string->number (file->lines docsfile)))
  (define rk-topics (map string->number (file->lines topicsfile)))

  (define words-size (length rk-words))
  (define docs-size (length rk-docs))
  (define topics-size (length rk-topics))
  (define num-docs (add1 (last rk-docs)))
  (define num-words (add1 (argmax identity rk-words)))
  (define num-topics (add1 (argmax identity rk-topics)))
  (printf "num-docs: ~a, num-words: ~a, num-topics: ~a\n" num-docs num-words num-topics)
  (printf "words-size: ~a, docs-size: ~a, topics-size: ~a\n" words-size docs-size topics-size)

  (define outfile (build-path output-dir testname "rkt" (format "~a-~a" num-topics num-docs)))

  (define full-info
    `(((array-info . ((size . ,num-topics))))
      ((array-info . ((size . ,num-words))))
      ((array-info . ((size . ,num-docs)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-topics 1))))))))))
      ((array-info . ((size . ,words-size)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-words 1)))))))
                      (value . ,rk-words))))
      ((array-info . ((size . ,words-size)
                      (elem-info . ((nat-info
                                     . ((value-range
                                         . (0 . ,(- num-docs 1)))))))
                      (value . ,rk-docs))))
      ((nat-info . ((value-range . (0 . ,(- num-docs 1))))))))

(define (run-test num-trials)
  (define init-time (get-time))

  (define module-env (compile-file srcfile full-info))
  (define init-rng (jit-get-function 'init-rng module-env))
  (init-rng)
  (elasp-time init-time))

(module+ test
  (run-test 1))

(module+ main
  (define (ms l) (define mn (mean l))
    (cons (mean l) (/ (stddev l) (sqrt (length l)))))
  (define s (for/list ([i (in-range 10)]) (run-test 50)))
  (printf "ran tests\n")
  (pretty-display (ms s))
  )
