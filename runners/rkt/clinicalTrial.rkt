#lang racket

(require sham
         hakrit)

(define module-env (compile-file "../../testcode/hkrkt/clinicalTrial_simp.hkr"))

(define prog (jit-get-function 'prog module-env))
(printf (current-command-line-arguments))

(define n)     ;(string->number (get-cmd-argument 0)))
(define xfile) ;(get-cmd-argument 1))
