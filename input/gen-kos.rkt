#lang racket
(require racket/runtime-path
         racket/cmdline)

(module+ main
  (define-values (input-file output-folder)
    (command-line #:args (i o)
                  (values i o)))
  (define kos (file->lines input-file))
  (define nnzs (cdddr kos))
  (define docs-file (open-output-file (build-path output-folder "docs") #:exists 'replace))
  (define words-file (open-output-file (build-path output-folder "words") #:exists 'replace))
  (for ([nnz nnzs])
    (match-define (list doc word cnt) (string-split nnz))
    (fprintf docs-file "~a\n" doc)
    (fprintf words-file "~a\n" word)))
