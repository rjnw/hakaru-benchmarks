benchmarks: clinicalTrial_simp.hs linearRegression_simp.hs gmm_gibbs_simp.hs naive_bayes_gibbs_simp.hs lda_gibbs_simp.hs

%_simp.hs: ../hksrc/%.hk
	../../hkbin/hk-maple -p haskell --timelimit=600 $< > $@
clean:
	rm *.hs
