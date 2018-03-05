.PHONY: all

mallet-2.0.8.tar.gz:
	wget http://mallet.cs.umass.edu/dist/mallet-2.0.8.tar.gz

mallet-2.0.8/bin/mallet: mallet-2.0.8.tar.gz
	tar -xvzf mallet-2.0.8.tar.gz
	touch ./mallet-2.0.8/bin/mallet

20newsgroup.mallet: mallet-2.0.8/bin/mallet
	./mallet-2.0.8/bin/mallet import-dir --input ../../input/20_newsgroups/* --output 20newsgroup.mallet

nb.classifier: 20newsgroup.mallet
	./mallet-2.0.8/bin/mallet train-classifier --input 20newsgroup.mallet --training-portion 0.9999 --trainer NaiveBayes --output-classifier nb.classifier

all: nb.classifier

clean:
	rm nb.classifier 20newsgroup.mallet

cleanall:
	rm mallet-2.0.8.tar.gz
	rm -R mallet-2.0.8
