#lang racket
(require hakrit)

(require hakrit
         hakrit/utils
         ffi/unsafe
         racket/cmdline
         racket/runtime-path
         disassemble
         "discrete.rkt"
         "utils.rkt")

(define testname "LdaLikelihood")
(define news-dir "news")
(define (run-test (num-trials 1))
  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))

  (define wordsfile  (build-path input-dir news-dir "words"))
  (define docsfile   (build-path input-dir news-dir "docs"))
  (define topicsfile   (build-path input-dir news-dir "topics"))

  (define rk-words (map string->number (file->lines wordsfile)))
  (define rk-docs (map string->number (file->lines docsfile)))
  (define rk-topics (map string->number (file->lines topicsfile)))

  (define words-size (length rk-words))
  (define docs-size (length rk-docs))
  (define topics-size (length rk-topics))
  (define num-docs (add1 (last rk-docs)))
  (define num-words (add1 (argmax identity rk-words)))
  (define num-topics (add1 (argmax identity rk-topics)))

  (define outfile (build-path output-dir testname "rkt" (format "~a-~a-~a" news-dir num-topics num-docs)))

  (define full-info
    `(((array-info . ((size . ,num-topics))))
      ((array-info . ((size . ,num-words))))
      ()
      ;; ((nat-info . ((value . ,num-docs))))
      ((array-info . ((size . ,words-size)
                      (value . ,rk-words))))
      ((array-info . ((size . ,words-size)
                      (value . ,rk-docs))))
      ((array-info . ((size . ,words-size))))))

  (printf "compiling\n")
  (define prog (compile-hakaru srcfile full-info))
  (printf "compiled\n")

  (printf "num-docs: ~a, num-words: ~a, num-topics: ~a\n" num-docs num-words num-topics)
  (printf "words-size: ~a, docs-size: ~a, topics-size: ~a\n" words-size docs-size topics-size)

  (define topics-prior (list->cblock (build-list num-topics (const 0.0)) _double))
  (printf "made topics-prior\n")
  (define words-prior (list->cblock (build-list num-words (const 0.0)) _double))
  (printf "made words-prior\n")

  (define words (list->cblock rk-words _uint64))
  (printf "made words\n")
  (define docs (list->cblock rk-docs _uint64))
  (printf "made docs\n")

  (lambda (z)
    (prog topics-prior words-prior num-docs words docs z)))



(module+ main
    (define num-trials
      (command-line #:args ((num-trials "1"))
                    (string->number num-trials)))
  (run-test num-trials))
