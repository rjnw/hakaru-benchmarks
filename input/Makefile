.PHONY : all

ct = clinicalTrial
lr = linearRegression
gg = gmmGibbs

n := 0 00 000 0000
i := 3 6 9 12
numbers=$(foreach i,$(n),1$(i))
ctinp=$(foreach n,$(numbers),./$(ct)/$n)
lrinp=$(foreach n,$(numbers),./$(lr)/$n)
gn=$(foreach n, $(numbers), ./$(gg)/$n)
gminp=$(foreach k, $(i), $(foreach g,$(gn),$(g)-$k))
tests := 2000

all: $(ctinp) $(lrinp) $(gminp)

./$(ct)/% : ./bin/$(ct)
	$< $(notdir $@) | head -n $(tests) > $@

./data/$(lr)/% :
	i=0;while [[ $$i -le $(notdir $@) ]];do\
		echo $$RANDOM >> $@;\
		((i = i + 1)); \
	done;

./$(lr)/% : ./data/$(lr)/%
	./bin/$(lr) $< | head -n $(tests) > $@

./data/$(gg)/%:
	yes 1 | head -n $(notdir $@) > $@

.SECONDEXPANSION:
./$(gg)/% : ./data/$(gg)/$$(shell cut -d- -f1 <<< $$(notdir $$@))
	./bin/gmmModel $< $(shell cut -d- -f2 <<< $(notdir $@)) | head -n 2000 > $@

clean:
	rm ./$(ct)/* ./$(lr)/* ./$(gg)/*
