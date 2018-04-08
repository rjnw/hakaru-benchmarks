.PHONY: GmmGibbs hkbin

hkbin:
	cd ./hk && make all

gmm-rkt:
	cd ./rkt && racket GmmGibbsOpt.rkt $(classes) $(points)
gmm-hs:
	./hkbin/gmmGibbs ../input/GmmGibbs/$(classes)-$(points) ../testcode/jagssrc ../output/

gmm-rkt-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/rkt/$(classes)-$(points)
gmm-hs-acc:
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/hk/$(classes)-$(points)
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/jags/$(classes)-$(points)


GmmGibbsAcc: gmm-rkt-acc gmm-hs-acc
GmmGibbsTrial: gmm-rkt gmm-hs

GmmGibbs: GmmGibbsTrial GmmGibbsAcc

NaiveBayes:
	./hkbin/naiveBayesGibbs ../input ../testcode/jagssrc ../output
