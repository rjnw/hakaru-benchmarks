.PHONY: GmmGibbs hkbin

hkbin:
	cd ./hk && make all
GmmGibbs:
	cd ./rkt && racket GmmGibbsOpt.rkt $(classes) $(points)
	# ./hkbin/gmmGibbs ../input/GmmGibbs/$(classes)-$(points) ../testcode/jagssrc ../output/
	# ./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/jags/$(classes)-$(points)
	# ./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/hk/$(classes)-$(points)
	./hkbin/gmmAccuracy ../input/GmmGibbs/$(classes)-$(points) ../output/GmmGibbs/rkt/$(classes)-$(points)
