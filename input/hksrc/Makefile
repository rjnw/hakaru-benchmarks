# .PHONY generators clean

generators: clinicalTrial gmmModel linearRegression

%.hs: %.hk
	../../hkbin/compile $<

%: %.hs
	cd ../../hakaru; stack exec -- ghc -O2 ../input/hksrc/$< -o ../input/bin/$@;
	rm *.hi *.o

clean:
	rm *.hi *.o

cleanbin:
	cd ../bin; rm clinicalTrial gmmModel linearRegression;
