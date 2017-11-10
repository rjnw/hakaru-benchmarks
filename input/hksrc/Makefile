.PHONY: generators
.PRECIOUS: %.hs

generators = $(foreach i,clinicalTrial gmmModel linearRegression, ../bin/$i)

all: $(generators)

%.hs: %.hk
	../../hkbin/compile $<

../bin/%: %.hs
	cd ../../hakaru; stack exec -- ghc -O2 ../input/hksrc/$< -o ../input/bin/$(notdir $@);

clean:
	rm *.hs *.hi *.o ../bin/*
