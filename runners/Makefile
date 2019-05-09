.PHONY: GmmGibbs hkbin

hkbin:
	cd ./hk && make all

gmm-rkt:
	mkdir -p ../output/GmmGibbs/rkt
	cd ./rkt && racket GmmGibbsOpt.rkt $(classes) $(points)
gmm-hs:
	./hkbin/gmmGibbs ../input/GmmGibbs/$(classes)-$(points) ../testcode/jagssrc ../output/
gmm-aug:
	cd ./augur && python2 gmm.py $(classes) $(points)
gmm-stan:
	cd ../other; make stan
	cd ../other/cmdstan-2.18.1; make gmm
	cd ../other/cmdstan-2.18.1; ./classify.px ../../input/GmmGibbs/$(classes)-$(points) > ../../output/accuracies/GmmGibbs/stan/$(classes)-$(points)

gmm-trial: gmm-rkt gmm-hs gmm-aug gmm-stan

gmm-rkt-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/rkt/$(classes)-$(points)
gmm-hs-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/hk/$(classes)-$(points)
gmm-jags-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/jags/$(classes)-$(points)
gmm-aug-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/augur/$(classes)-$(points)
gmm-acc: gmm-rkt-acc gmm-hs gmm-jags-acc gmm-aug-acc
gmm: gmm-trial gmm-acc

nb-rkt:
	cd ./rkt && racket NaiveBayesGibbsOpt.rkt $(trials) $(sweeps) $(trial-time) $(holdout-modulo)
nb-rkt-ll:
	./hkbin/nbLikelihood ../input/news/ ../output/NaiveBayesGibbs/rkt/20-19997-$(holdout-modulo) ../output/accuracies/NaiveBayesGibbs/rkt/20-19997-$(holdout-modulo) 20

nb-hk:
	./hkbin/naiveBayesGibbs ../input ../testcode/jagssrc ../output
nb-jags-ll:
	./hkbin/nbLikelihood ../input/news/ ../output/NaiveBayesGibbs/jags/20-19997-$(holdout-modulo) ../output/accuracies/NaiveBayesGibbs/jags/20-19997-$(holdout-modulo) 20


nb-augur:
	cd ./augur && python2 nb.py ../../input/news/ ../../output/NaiveBayesGibbs/augur/ $(trials) $(sweeps) $(trial-time) $(holdout-modulo)
nb-augur-ll:
	./hkbin/nbLikelihood ../input/news/ ../output/NaiveBayesGibbs/augur/20-19997-$(holdout-modulo) ../output/accuracies/NaiveBayesGibbs/augur/20-19997-$(holdout-modulo) 20

lda-rkt:
	cd ./rkt && racket LdaGibbsOpt.rkt ../../input/kos/ ../../output/LdaGibbs/kos/ $(topics) $(trials)
	./hkbin/ldaLikelihood ../input/kos/ ../output/LdaGibbs/kos/rkt-$(topics)   ../output/accuracies/LdaGibbs/kos/rkt-$(topics) $(topics)

lda-augur:
	cd ./augur && python2 ./lda.py ../../input/kos/ ../../output/LdaGibbs/kos/ $(topics) $(trials)
	./hkbin/ldaLikelihood ../input/kos/ ../output/LdaGibbs/kos/augur-$(topics)   ../output/accuracies/LdaGibbs/kos/augur-$(topics) $(topics)
