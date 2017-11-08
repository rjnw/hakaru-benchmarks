benchmarks: clinicalTrial_simp.hkr linearRegression_simp.hkr gmm_gibbs_simp.hkr naive_bayes_gibbs_simp.hkr lda_gibbs_simp.hkr

%_simp.hkr: ../hksrc/%.hk
	../../hkbin/hk-maple -p sexpression --timelimit=600 $< > $@
clean:
	rm *.hkr
