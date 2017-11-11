all: ClinicalTrial.hkr  GmmGibbs.hkr  LdaGibbs.hkr  LinearRegression.hkr  NaiveBayesGibbs.hkr

%.hkr: ../hksrc/%.hk
	../../hkbin/hk-maple -p sexpression --timelimit=600 $< > $@

clean:
	rm *.hkr
