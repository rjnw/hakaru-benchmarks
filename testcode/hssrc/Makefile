

all: ClinicalTrial.hs  GmmGibbs.hs  LdaGibbs.hs  LinearRegression.hs  NaiveBayesGibbs.hs

%.hs: ../hksrc/%.hk
	../../hkbin/hk-maple -p haskell --timelimit=600 $< > $@
clean:
	rm *.hs
