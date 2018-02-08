#lang racket
(require plot
         math/statistics)

(define (parse runner classes points)
  (define accuracy-file (build-path "./accuracies/GmmGibbs/" (format "~a/~a-~a" runner classes points)))
  (define trials (file->lines accuracy-file))
  (define (get-snapshots st)
    (define f (compose inexact->exact string->number))
    (map (λ (s) (match-define (list tim sweep state) s)
            (list (string->number tim)
                  (f sweep)
                  (map string->number (regexp-match* #px"\\d+\\.?\\d*" state))))
         (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr)))

  (define (time-sweep-accuracy snapshots)
    (for/list ([shot snapshots])
      (define sweep (second shot))
      (define tim (first shot))
      (define acc  (first (third shot)))
      ;; (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
      (list tim sweep acc)))
  (map (compose time-sweep-accuracy get-snapshots) trials))

(define (mean-accuracy al)
  (if (ormap empty? al)
      '()
      (cons (let ([c (map car al)])
              (list (mean (map first c)) (mean (map third c))))
            (mean-accuracy (map cdr al)))))

(module+ main
  (define-values (classes points)
    (command-line #:args (classes points)
                  (values (string->number classes)
                          (string->number points))))
  (plot-file
   (list
    (lines (mean-accuracy (parse "rkt" 6 1000)) #:color 1 #:label "rkt")
    (lines (mean-accuracy (parse "hk" 6 1000)) #:color 2 #:label "haskell")
    (lines (mean-accuracy (parse "jags" 6 1000)) #:color 3 #:label "jags"))
   "GmmGibbs.pdf"
   #:y-max 1 #:y-min 0.7
   #:y-label "accuracy" #:x-label "time"
   )

  )

(module+ test
  (plot (list
         (lines (mean-accuracy (parse "rkt" 6 1000)) #:color 1 #:label "rkt")
         (lines (mean-accuracy (parse "hk" 6 1000)) #:color 2 #:label "haskell")
         (lines (mean-accuracy (parse "jags" 6 1000)) #:color 3 #:label "jags"))
        #:y-max 1 #:y-min 0.7
        #:y-label "accuracy" #:x-label "time"
        ))
