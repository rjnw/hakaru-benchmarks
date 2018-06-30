#lang racket

(require racket/cmdline
         racket/runtime-path)
(require racket/draw
         plot)
(define source-dir "../testcode/hkrkt/")

(define (trial->tsa trial)
  (define (get-snapshots st)
    (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
    (define f string->number)
    (map (λ (s) (match-define (list tim sweep state) s)
            (list (string->number tim)
                  (f sweep)
                  (map f (regexp-match* #px"-?\\d+\\.?\\d*" state))))
         snapshots))
  (define sshots (get-snapshots trial))
  (for/list ([shot sshots])
    (define sweep (second shot))
    (define tim (first shot))
    (define acc (first (third shot)))
    (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
    (list tim sweep acc)))

(define trials->tsa (curry map trial->tsa))

(define (parse runner)
  (trials->tsa (file->lines (build-path "./accuracies/LdaGibbs/" runner))))
(define (recalculate-time tsa)
  (define-values (_ ntsa)
    (for/fold ([t 0]
               [ntsa '()])
              ([v tsa])
      (match-define (list tim sweep acc) v)
      (values (+ t tim) (cons (list (+ t tim) sweep acc) ntsa))))
  (reverse ntsa))

(define rkt-orig (last (parse "kos-rkt-50")))
(define rkt-trials rkt-orig)
(define augur-orig (car (parse "kos-augur-50")))
(define augur-trials (recalculate-time augur-orig))
(define (get-xy tsa)
  (for/list ([t tsa])
    (list (first t) (third t))))

(define rkt-xy (get-xy rkt-trials))
(define augur-xy (get-xy augur-trials))

(define (get-line trial lcolor lstyle icolor istyle legend pstyle  (i 1) (point-size 6))
  (list
   ;; (lines-interval
   ;;  (sort (for/list ([(k v) tsa])
   ;;          (list k (+ (mean (map car v))
   ;;                     (/ (stddev (map car v))
   ;;                        (sqrt (length (map car v)))))))
   ;;        (λ (v1 v2) (< (car v1) (car v2))))
   ;;  (sort (for/list ([(k v) tsa])
   ;;          (list k  (- (mean (map car v))
   ;;                      (/ (stddev (map car v))
   ;;                         (sqrt (length (map car v)))))))
   ;;        (λ (v1 v2) (< (car v1) (car v2))))
   ;;  #:color icolor #:style istyle
   ;;  #:line1-style 'transparent #:line2-style 'transparent
   ;;  #:alpha 0.3)

   ;; (points
   ;;  (for/list ([(s ta) smta]
   ;;             #:when (zero? (modulo s 10)))
   ;;    ta)
   ;;  #:size point-size #:color lcolor #:sym pstyle)
   (points
    trial
    #:size point-size #:alpha 0.1 #:line-width 1
    #:color lcolor #:sym pstyle)

   (lines
    trial
    #:color lcolor #:style lstyle
    #:width 1
    #:label legend)
   )
  )


(plot-file
 (list
  (get-line rkt-xy
            (make-object color% 0 73 73) 'solid
            (make-object color% 0 146 146) 'solid
            "Hakaru" 'triangle)

  (get-line augur-xy
            (make-object color% 73 0 146) 'solid
            (make-object color% 0 146 146) 'solid
            "AugurV2" 'square)
  )
  "ldalikelihood.pdf"
 ;; #:y-min -31000000
 )