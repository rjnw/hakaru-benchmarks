#lang racket
(require racket/runtime-path
         "plot-tsa.rkt"
         math/statistics
         racket/draw
         plot)

(define testname "NaiveBayesGibbs")
(define input-dir "../input/")
(define  output-dir "./")

(define newsd "news")
(define wordsfile  (build-path input-dir newsd "words"))
(define docsfile   (build-path input-dir newsd "docs"))
(define topicsfile   (build-path input-dir newsd "topics"))

(define holdout-modulo 10)
(define (holdout? i) (zero? (modulo i holdout-modulo)))

(define true-topics (map string->number (file->lines topicsfile)))
(define (accuracy predict-topics)
  (define-values (correct total)
    (for/fold ([correct-topics '()]
               [total-docs '()])
              ([i (in-range (length true-topics))]
               [true-topic true-topics]
               [predict-topic predict-topics]
               #:when  (holdout? (add1 i))
               )
      (values (if (equal? true-topic predict-topic)
                  (cons i correct-topics)
                  correct-topics)
              (cons i total-docs))))
  ;; (printf "acc: ~a/~a\n" (length correct) (length total))
  (/ (* (length correct) 1.0) (length total)))

(define num-topics 20)
(define num-docs 19997)

(define rkt-test (build-path output-dir testname "rkt" (format "~a-~a" num-topics num-docs)))
(define hk-test (build-path output-dir testname "hk" (format "~a-~a" num-topics num-docs)))
(define jags-test (build-path output-dir testname "jags" (format "~a-~a" num-topics num-docs)))

(define (get-snapshots st)
  (define snapshots (regexp-match* #px"(\\d*\\.?\\d*) (\\d*\\.?\\d*) \\[(.*?)\\]" st #:match-select cdr))
  (define f (compose inexact->exact string->number))
  (map (λ (s) (match-define (list tim sweep state) s)
          (list (string->number tim)
                (f sweep)
                (map f (regexp-match* #px"\\d+\\.?\\d*" state))))
       snapshots))

(define (trial->tsa trial)
  (define sshots (get-snapshots trial))
  (for/list ([shot sshots])
    (define sweep (second shot))
    (define tim (first shot))
    (define acc (accuracy (third shot)))
    ;; (printf "sweep: ~a, time: ~a, accuracy: ~a\n" sweep tim acc)
    (list tim sweep acc)))

(define (str-trials->time-sweep-accuracy trials)
  (for/list ([trial trials])
    (trial->tsa trial)))

(begin (define rkt-trials (str-trials->time-sweep-accuracy (file->lines rkt-test)))
       (define hs-trials (str-trials->time-sweep-accuracy (file->lines hk-test)))
       (define jags-trials (cons
                            '((22793.95 1 0.776888444222111)
                             (23311.4 2 0.806903451725863)
                             (23833.82 3 0.8139069534767384)
                             (24358.23 4 0.817408704352176)
                             (24882.86 5 0.8164082041020511))
                            (str-trials->time-sweep-accuracy (file->lines jags-test))))
       ;; (define jags-trials
         ;; '(((22793.95 1 0.776888444222111)
         ;;    (23311.4 2 0.806903451725863)
         ;;    (23833.82 3 0.8139069534767384)
         ;;    (24358.23 4 0.817408704352176)
         ;;    (24882.86 5 0.8164082041020511)))

       ;;   (list (for/list ([line (length (file->lines "./NaiveBayesGibbs/jags/manual-20-19997"))])
       ;;   (define vs (map string->number (string-split line " ")))
       ;;   (define t (car vs))
       ;;   (define sweeps (cadr vs))
       ;;   (define z (map sub1 (cddr vs)))
       ;;   (list t sweeps (accuracy z))))
       ;;   )
       )
;; (define hk-trials (str-trial->time-sweep-accuracy (file->lines hk-test)))

(define (remove-warmup tsa)
  (for/list ([trial tsa])
    (define min-time (first (first trial)))
    (map (λ (shot) (list (- (first shot) min-time) (second shot) (third shot))) trial)))

(begin (define rkt-sta (run->sweep-time.accuracy rkt-trials))
       (define hs-sta (run->sweep-time.accuracy hs-trials))
       (define jags-sta (run->sweep-time.accuracy jags-trials))
       (define rkt-mta (sort (sweep-time.accuracy->mean$time.accuracy rkt-sta)
                             (λ (v1 v2) (< (car v1) (car v2)))))
       (define jags-mta (sort (sweep-time.accuracy->mean$time.accuracy jags-sta)
                              (λ (v1 v2) (< (car v1) (car v2)))))
       (pretty-display rkt-mta)
       (pretty-display jags-mta)

       (parameterize
           (;; [plot-x-transform log-transform]
            )
         (plot-file (list  (lines rkt-mta #:color (make-object color% 0 73 73)  #:label "hakrit" )
                           ;; (lines jags-mta #:color (make-object color% 146 0 0)  #:label "jags" )
                           ;; (points jags-mta #:size 6 #:color (make-object color% 146 0 0) #:sym 'diamond)
                           ;; (points rkt-mta #:size 6 #:color (make-object color% 0 73 73) #:sym 'triangle)
                           ;; (lines (first hk-points) #:color 5 #:label "haskell")
                           )
                    "nb-plot.pdf"

                    ;; #:y-min 0.97
                    #:legend-anchor 'bottom-right
                    #:x-label "sweep"
                    #:y-label "accuracy"
                    #:title "NaiveBayesGibbs"))

       )

;; (define (f n) (~r n #:precision 4))
;;  (for ([(sweep sta) rkt-sta])
;;    (define tim (map car (cdr sta)))
;;    (define acc (map cadr (cdr sta)))
;;    (printf "~a & ~a & ~a & ~a\\\\\n" sweep (f (mean tim))
;;            (~r (mean acc) #:precision 4)
;;            (f (/ (stddev acc)
;;                (sqrt (length acc))))))

;; (define (ms l) (define mn (mean l))
;;   (cons (mean l) (/ (stddev l) (sqrt (length l)))))

;; (for/list ([(s ta) jags-sta])
;;   (define acs (map second ta))
;;   (define msg (ms acs))
;;   (define rktacs (map second (hash-ref rkt-sta s)))
;;   (define rsg (ms rktacs))
;;   (printf "~a & ~a & ~a & ~a & ~a\\\\\n" s (f (car msg)) (f (cdr msg)) (f (car rsg)) (f (cdr rsg))))

;; (define hs-st (flatten (for/list ([i (in-range 1 5)]) (map - (map car (hash-ref hs-sta (+ i 1)))(map car (hash-ref hs-sta i))))))
;; (define rkt-st (flatten (for/list ([i (in-range 1 10)]) (map - (map car (hash-ref rkt-sta (+ i 1)))(map car (hash-ref rkt-sta i))))))
;; (define jags-st (flatten (for/list ([i (in-range 1 5)]) (map - (map car (hash-ref jags-sta (+ i 1)))(map car (hash-ref jags-sta i))))))
;; (define rkt-ut (map (λ (t) (/ (* t 1000) 2000)) rkt-st))
;; (define hs-ut (map (λ (t) (/ (* t 1000) 2000)) hs-st))
;; (define jags-ut (map (λ (t) (/ (* t 1000) 2000)) jags-st))
;; ;; mallet
;; (define mal-ut (flatten (map cdr
;;                      '((463 177 263 175 159 190 162 153 152)
;;                        (466 186 288 201 183 208 189 190 176 173)
;;                        (436 178 231 143 174 170 160 187 151)
;;                        (498 187 260 201 179 207 183 187 173)
;;                        (440 186 264 203 190 180 204 180 185)
;;                        ))))

;; ;; hakrit std-dev 0.33
;; ;; hakaru std-dev 2.4


;; ;; mallet ut '(189.9512195121951 . 4.87010954164942)
;; ;; rkt ut '(21.322516666666665 . 0.04620972550753222)
;; ;; jags ut '(261.11375 . 0.7223753677105466)

;; (plot-file (discrete-histogram '((Hakaru 21.322)
;;                                  (Mallet 189.95)
;;                                  (JAGS 261.11))
;;                                #:invert? #t)
;;            "update-time-test.pdf"
;;            #:y-label "language"
;;            #:x-label "update time in milliseconds."
;;            #:x-max 300)
;; ;; (ms '(205.57299999999998 198.67399999999998 195.018 222.543 228.468 215.833 220.774 217.91699999999997 218.77 224.348 222.416 249.633 251.121 242.812 238.864 243.856 2
;; 11.852 226.07899999999998 217.446 214.637 209.927))
;; %% mallet single update times
;; %% '((463 177 263 175 159 190 162 153 152)
;; %%   (466 186 288 201 183 208 189 190 176 173)
;; %%   (436 178 231 143 174 170 160 187 151)
;; %%   (498 187 260 201 179 207 183 187 173)
;; %%   (440 186 264 203 190 180 204 180 185))

;; %% racket sweep time with holdout 10\% so around 2000 updates
;; %% sweep & mean time & mean accuracy & stderr accuracy\\
;; %% 1 & 42.3702 & 0.8211 & 0.0011\\
;; %% 2 & 84.648 & 0.8233 & 0.0009\\
;; %% 3 & 126.9518 & 0.822 & 0.0012\\
;; %% 4 & 169.3269 & 0.8213 & 0.0008\\
;; %% 5 & 211.7622 & 0.8207 & 0.0006\\
;; %% 6 & 254.1721 & 0.8204 & 0.001\\
;; %% 7 & 296.7254 & 0.8203 & 0.001\\
;; %% 8 & 339.3306 & 0.8209 & 0.0006\\
;; %% 9 & 382.2402 & 0.8208 & 0.0005\\
;; %% 10 & 425.4006 & 0.8219 & 0.0004\\

;; %% jags sweep timing
;; %% '#hash((4 . ((24358.23 0.817408704352176)))
;; %%        (3 . ((23833.82 0.8139069534767384)))
;; %%        (2 . ((23311.4 0.806903451725863)))
;; %%        (1 . ((22793.95 0.776888444222111)))
;; %%        (5 . ((24882.86 0.8164082041020511))))
