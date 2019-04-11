#lang racket
(require hakrit)

(require hakrit
         hakrit/utils
         ffi/unsafe
         racket/cmdline
         racket/runtime-path
         disassemble
         "discrete.rkt"
         "gmm-utils.rkt")

(define testname "LdaGibbs")
(define news-dir "news")
(define (run-test input-dir output-dir num-topics num-trials)

  (define srcfile (build-path hksrc-dir (string-append testname ".hkr")))
  (define outfile (build-path output-dir (format "~a-~a" "rkt" num-topics)))
  (define wordsfile  (build-path input-dir "words"))
  (define docsfile   (build-path input-dir "docs"))

  (define rk-words (map string->number (file->lines wordsfile)))
  (define rk-docs (map string->number (file->lines docsfile)))

  (define words-size (length rk-words))
  (define num-docs (add1 (last rk-docs)))
  (define num-words (add1 (argmax identity rk-words)))

  (printf "words-size: ~a, num-docs: ~a, num-words: ~a, num-topics: ~a\n" words-size num-docs num-words num-topics)
  (define full-info
    `((topic_prior . ((array-info . ((size . ,num-topics)))))
      (word_prior . ((array-info . ((size . ,num-words)))))
      ;; ()
      ;; ((nat-info . ((value . ,num-docs))))
      (w . ((array-info . ((size . ,words-size)
                           ;; (value . ,rk-words)
                           ))))
      (doc . ((array-info . ((size . ,words-size)
                             ;; (value . ,rk-docs)
                             ))))
      (z . ((array-info . ((size . ,words-size)))))
      ;; ((nat-info . ((value-range . (0 . ,(- num-words 1))))))
      ))

  (define topics-prior (list->cblock (build-list num-topics (const 0.0)) _double))
  (define words-prior (list->cblock (build-list num-words (const 0.0)) _double))

  (define words (list->cblock rk-words _uint64))
  (define docs (list->cblock rk-docs _uint64))

  (define distf (discrete-sampler 0 (- num-topics 1)))
  (define z (malloc _uint64 words-size))
  ;; (for ([i (in-range words-size)])
  ;;   (nat-array-set! z i (distf)))

  (printf "input-done\n")
  (define t0 (get-time))
  (define module-env (compile-file srcfile full-info))
  (define prog (get-prog module-env))
  (printf "compile-time: ~a\n" (elasp-time t0))

  (define (update z word-update)
    (prog topics-prior words-prior num-docs words docs z word-update))
  (printf "compiled, now running...\n")

  (define (run-single out-port)
    (define (snap tim position)
      (printf "taking snapshot: ~a, ~a\n" position tim)
      (fprintf out-port "~a ~a [" (~r tim #:precision '(= 3)) position)
      (for ([i (in-range (- words-size 1))])
        (fprintf out-port "~a " (fixed-hakrit-array-ref z 'nat i)))
      (fprintf out-port "~a]\t" (fixed-hakrit-array-ref z 'nat (- words-size 1))))
    (define time0 (get-time))
    (define (loop i)
      (when (< (elasp-time time0) 1000)
        (when (zero? (modulo i 10000))
          (snap (elasp-time time0) i))
        (fixed-hakrit-array-set! z 'nat i (update z i))
        (loop (modulo (add1 i) words-size))))
    (loop 0)
    (snap (elasp-time time0) words-size)
    (fprintf out-port "\n"))

  (call-with-output-file outfile #:exists 'replace
    (λ (out-port)
      (for ([i (in-range num-trials)])
        (for ([i (in-range words-size)])
          (fixed-hakrit-array-set! z 'nat i (distf)))
        (run-single out-port)))))

(module+ main
  (match-define (vector input-folder output-dir num-topics num-trials) (current-command-line-arguments))
  (run-test input-folder output-dir (string->number num-topics) (string->number num-trials)))

 ;; racket LdaGibbs.rkt ../../input/kos/ ../../output/LdaGibbs/kos/ 50 1
