.PHONY: GmmGibbs hkbin

hkbin:
	cd ./hk && make all

gmm-rkt:
	cd ./rkt && racket GmmGibbsOpt.rkt $(classes) $(points)
gmm-hs:
	./hkbin/gmmGibbs ../input/GmmGibbs/$(classes)-$(points) ../testcode/jagssrc ../output/
gmm-aug:
	cd ./augur && python2 gmm.py $(classes) $(points)

gmm-rkt-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/rkt/$(classes)-$(points)
gmm-hs-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/hk/$(classes)-$(points)
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/jags/$(classes)-$(points)
gmm-aug-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/augur/$(classes)-$(points)

GmmGibbsAcc: gmm-rkt-acc gmm-hs-acc gmm-aug-acc
GmmGibbsTrial: gmm-rkt gmm-hs gmm-aug

GmmGibbs: GmmGibbsTrial GmmGibbsAcc

NaiveBayes:
	./hkbin/naiveBayesGibbs ../input ../testcode/jagssrc ../output

# NaiveBayesJags:
# 	R "

lda-rkt:
	cd ./rkt && racket LdaGibbs.rkt ../../input/kos/ ../../output/LdaGibbs/kos/ $(topics) $(trials)
	./hkbin/ldaLikelihood ../input/kos/ ../output/LdaGibbs/kos/rkt-$(topics)   ../output/accuracies/LdaGibbs/kos/rkt-$(topics) $(topics)

lda-augur:
	cd ./augur && python2 ./lda.py ../../input/kos/ ../../output/LdaGibbs/kos/ $(topics) $(trials)
	./hkbin/ldaLikelihood ../input/kos/ ../output/LdaGibbs/kos/augur-$(topics)   ../output/accuracies/LdaGibbs/kos/augur-$(topics) $(topics)
