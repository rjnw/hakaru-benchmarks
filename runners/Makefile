.PHONY: GmmGibbs hkbin

hkbin:
	cd ./hk && make all
GmmGibbs: hkbin
	cd ./rkt && racket GmmGibbsOpt.rkt 6 100
	./hkbin/gmmGibbs ../input/GmmGibbs/6-100 ../testcode/jagssrc ../output/
	./hkbin/gmmAccuracy ../input/GmmGibbs/6-100 ../output/GmmGibbs/jags/6-100
	./hkbin/gmmAccuracy ../input/GmmGibbs/6-100 ../output/GmmGibbs/hk/6-100
	./hkbin/gmmAccuracy ../input/GmmGibbs/6-100 ../output/GmmGibbs/rkt/6-100
	cd ../output/accuracies && Rscript plots.r GmmGibbs 6-100 plots.pdf
