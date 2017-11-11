.PHONY: all

all: ClinicalTrialSimp.hk  GmmGibbsSimp.hk  LdaGibbsSimp.hk  LinearRegressionSimp.hk  NaiveBayesGibbsSimp.hk

%Simp.hk: ../hksrc/%.hk
	../../hkbin/hk-maple --timelimit=600 $< | ./unsample > $@

clean:
	rm *.hk
