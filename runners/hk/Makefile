.PHONY: all
hssrc = ../../testcode/hssrc/

benchmarks = ClinicalTrial LinearRegression GmmGibbs NaiveBayesGibbs LdaGibbs

GmmGibbs/Accuracy:
	cd GmmGibbs; stack exec -- ghc -O2 Accuracy.hs

all:
	stack build && stack install --local-bin-path ../hkbin

%/Prog.hs:
	mkdir -p $@
	cp $(hssrc)$@.hs $@

%/Main.hs:
	mkdir -p $@
	cp MainTemplate.hs $@
