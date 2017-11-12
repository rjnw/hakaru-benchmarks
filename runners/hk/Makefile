.PHONY: all
hssrc = ../../testcode/hssrc/

benchmarks = ClinicalTrial LinearRegression GmmGibbs NaiveBayesGibbs LdaGibbs

all:
	stack build && stack install --local-bin-path ../hkbin

%/Prog.hs:
	mkdir -p $@
	cp $(hssrc)$@.hs $@

%/Main.hs:
	mkdir -p $@
	cp MainTemplate.hs $@
