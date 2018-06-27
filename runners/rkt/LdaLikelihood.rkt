#lang racket
(require hakrit)

(require hakrit
         hakrit/utils
         ffi/unsafe
         racket/cmdline
         racket/runtime-path)

(define testname "LdaLikelihood")
(define news-dir "news")

(define input-dir "../input/")
(define  output-dir "./")

(define srcfile (build-path hksrc-dir (string-append testname ".hkr")))

(define wordsfile (build-path input-dir news-dir "words"))
(define docsfile (build-path input-dir news-dir "docs"))
(define topicsfile (build-path input-dir news-dir "topics"))

(define rk-words (map string->number (file->lines wordsfile)))
(define rk-docs (map string->number (file->lines docsfile)))
(define rk-topics (map string->number (file->lines topicsfile)))

(define words-size (length rk-words))
(define docs-size (length rk-docs))
(define topics-size (length rk-topics))
(define num-docs (add1 (last rk-docs)))
(define num-words (add1 (argmax identity rk-words)))
(define num-topics (add1 (argmax identity rk-topics)))

(define prog (compile-hakaru srcfile full-info))

(define (likelihood z)
  ;; (define outfile (build-path output-dir testname "rkt" (format "~a-~a-~a" news-dir num-topics num-docs)))
  (define full-info
    `(((array-info . ((size . ,num-topics))))
      ((array-info . ((size . ,num-words))))
      () ;; ((nat-info . ((value . ,num-docs))))
      ((array-info . ((size . ,words-size)
                      (value . ,rk-words))))
      ((array-info . ((size . ,words-size)
                      (value . ,rk-docs))))
      ((array-info . ((size . ,words-size))))))

  (define topics-prior (list->cblock (build-list num-topics (const 0.0)) _double))
  (define words-prior (list->cblock (build-list num-words (const 0.0)) _double))
  (define words (list->cblock rk-words _uint64))
  (define docs (list->cblock rk-docs _uint64))
  (define z (list->cblock z _uint64))
  (prog topics-prior words-prior num-docs words docs z))

(define (trial->tsa trial)
  (define (get-snapshots st)
    (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
    (define f (compose inexact->exact string->number))
    (map (λ (s) (match-define (list tim sweep state) s)
            (list (string->number tim)
                  (f sweep)
                  (map f (regexp-match* #px"\\d+\\.?\\d*" state))))
         snapshots))
  (define sshots (get-snapshots trial))
  (for/list ([shot sshots])
    (define sweep (second shot))
    (define tim (first shot))
    (define acc (likelihood (third shot)))
    ;; (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
    (list tim sweep acc)))

(define trials->tsa (curry map trial-tsa))



(module+ main
  ;; (define num-trials
  ;;   (command-line #:args ((num-trials "1"))
  ;;                 (string->number num-trials)))
  ;; (run-test num-trials)
  (get-ll)
  )
