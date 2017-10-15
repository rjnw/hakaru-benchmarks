benchmarks: clinicalTrial_simp.hs linearRegression_simp.hs gmm_gibbs_simp.hs naive_bayes_gibbs_simp.hs lda_gibbs_simp.hs

%_simp.hs: ../hksrc/%.hk
	compile --logfloat-prelude `cat $<` -o $@
	#figure out how to create haskell file from the tests
clean:
	rm *.hs
