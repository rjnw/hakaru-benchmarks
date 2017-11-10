.PHONY: all

ct = clinicalTrial
lr = linearRegression
gg = gmmGibbs

n := 0 00 000 0000
i := 3 6 9 12
numbers=$(foreach i,$(n),1$(i))
ctinp=$(foreach n,$(numbers),./$(ct)/$n)

lrinp-y=$(foreach n,$(numbers),./$(lr)/y/$n)
lrinp-dataX=$(foreach n,$(numbers),./$(lr)/dataX/$n)
gn=$(foreach n, $(i), ./$(gg)/$n)
gminp=$(foreach k, $(numbers), $(foreach g,$(gn),$(g)-$k))

tests := 2000

all: buildgen $(ctinp) $(lrinp-y) $(lrinp-datax) $(gminp)

buildgen:
	cd ./hksrc && make all

#clinical Trial
# we just generate 2000 values for each 10,100,1000,10000 and store it in ./clinicalTrial/<10,100,1000>
./$(ct)/% :
	mkdir -p $(dir $@)
	./bin/$(ct) $(notdir $@) | head -n $(tests) > $@

#linear Regression first needs random arrays dataX
# this rule will just generate number in name of file
./$(lr)/dataX/% :
	mkdir -p $(dir $@)
	i=0;while [[ $$i -le $(notdir $@) ]];do\
		echo $$RANDOM >> $@;\
		((i = i + 1)); \
	done;
#array of y, depends on dataX- of same length
./$(lr)/y/% : ./$(lr)/dataX/%
	mkdir -p ./$(lr)/y
	./bin/$(lr) $< | head -n $(tests) > $@

./data/$(gg)/%:
	mkdir -p $(dir $@)
	yes 1 | head -n $(notdir $@) > $@

.SECONDEXPANSION:
./$(gg)/% : ./data/$(gg)/$$(shell cut -d- -f1 <<< $$(notdir $$@))
	mkdir -p $(dir $@)
	./bin/gmmModel $< $(shell cut -d- -f2 <<< $(notdir $@)) | head -n 2000 > $@

cleaninp:
	rm -R ./$(ct) ./$(lr) ./$(gg)
	cd ./hksrc; make clean
