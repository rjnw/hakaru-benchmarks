.PHONY : all

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

all: $(ctinp) $(lrinp-y) $(lrinp-datax) $(gminp)
#clinical Trial
# we just generate 2000 values for each 10,100,1000,10000 and store it in ./clinicalTrial/<10,100,1000>
./$(ct)/% : ./bin/$(ct)
	$< $(notdir $@) | head -n $(tests) > $@

#linear Regression first needs random arrays dataX
# this rule will just generate number in name of file
./$(lr)/dataX/% :
	i=0;while [[ $$i -le $(notdir $@) ]];do\
		echo $$RANDOM >> $@;\
		((i = i + 1)); \
	done;
#array of y, depends on dataX- of same length
./$(lr)/y/% : ./$(lr)/dataX/%
	./bin/$(lr) $< | head -n $(tests) > $@

./data/$(gg)/%:
	yes 1 | head -n $(notdir $@) > $@

.SECONDEXPANSION:
./$(gg)/% : ./data/$(gg)/$$(shell cut -d- -f1 <<< $$(notdir $$@))
	./bin/gmmModel $< $(shell cut -d- -f2 <<< $(notdir $@)) | head -n 2000 > $@

clean:
	rm ./$(ct)/* ./$(lr)/* ./$(gg)/*
