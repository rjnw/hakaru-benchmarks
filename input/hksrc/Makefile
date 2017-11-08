.PHONY generators clean

generators: clinicalTrial gmmModel linearRegression

%.hs: %.hk
	../../hkbin/compile $<

%: %.hs
	cd ../../hakaru; stack exec -- ghc -O2 ../input/hksrc/$< -o ../input/hksrc/$@

clean:
	rm *.hs
	rm *.hi
	rm *.o
	rm clinicalTrial gmmModel linearRegression
