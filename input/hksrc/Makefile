.PHONY: generators
.PRECIOUS: %.hs

generators = $(foreach i,ClinicalTrial GmmModel LinearRegression, ../bin/$i)

all: $(generators)

%.hs: %.hk
	../../hkbin/compile $<

../bin/%: %.hs
	mkdir -p $(dir $@)
	cd ../../hakaru; stack exec -- ghc -O2 ../input/hksrc/$< -o ../input/bin/$(notdir $@);

clean:
	rm *.hs *.hi *.o ../bin/*
