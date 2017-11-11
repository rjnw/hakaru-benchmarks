.PHONY: all
hssrc = ../../testcode/hssrc/

benchmarks = ClinicalTrial LinearRegression GmmGibbs NaiveBayesGibbs LdaGibbs

all: $(benchmarks)

%:
	mkdir -p $@
	cp $(hssrc)$@.hs $@/Prog.hs
	cp MainTemplate.hs $@/Main.hs

clean:
	rm -R $(benchmarks)
