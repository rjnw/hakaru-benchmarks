.PHONY: setup submodule-init build-hakaru build-rkt build-input clean docker BenchmarkGmmGibbs

setup: submodule-init build-hakaru build-rkt build-augur copy-augur-lib build-haskell build-psi build-stan

submodule-init:
	git submodule init
	git submodule update

build: build-hakaru build-rkt build-augur build-psi build-haskell build-stan

build-hakaru:
	cd ./hakaru ; stack build && stack install --local-bin-path ../hkbin

generate-testcode:
	cd ./testcode/hkrkt ; make
	cd ./testcode/hksimp ; make
	cd ./testcode/hssrc ; make

build-rkt:
	raco pkg install --skip-installed disassemble
	cd ./rcf; raco pkg install --skip-installed --deps search-auto
	cd ./sham ; raco pkg install --skip-installed --deps search-auto
	cd ./hakrit ; raco pkg install --skip-installed --deps search-auto

build-augur:
	cd other/augurv2/compiler/augur; stack build
	cd other/augurv2/cbits; make libcpu
	cd other/augurv2/pyaugur; sudo python2 setup.py install

copy-augur-lib:
	$(eval LIBFILE=$(shell cd other/augurv2/compiler/augur; ls `stack path --dist-dir`/build/*so))
	mkdir -p other/augurv2/lib
	cp other/augurv2/compiler/augur/$(LIBFILE) other/augurv2/lib/libHSaugur-0.1.0.0.so


build-haskell:
	cd ./runners; make hkbin

build-psi:
	cd ./other; make psi

build-stan:
	cd ./other; make stan

build-input: get20newsgroup
	cd ./input; make all
	mkdir -p ./input/data/GmmGibbs
	cd ./input; make gmm classes=25 points=5000 trials=50
	cd ./input; make gmm classes=50 points=10000 trials=50

get20newsgroup:
	cd ./input; ./download-data.sh

clean:
	cd ./hakaru; stack clean
	cd ./input; make clean
	rm ./hkbin/*
	cd ./testcode/hkrkt ; make clean
	cd ./testcode/hksimp ; make clean
	cd ./testcode/hssrc ; make clean

docker:
	cd ./docker; sudo docker build -t hakaru-benchmark .

# GMMGibbs
gmm-input:
	cd ./input; make gmm classes=$(classes) points=$(points) trials=$(trials)
gmm-trial:
	cd ./runners; make gmm-trial classes=$(classes) points=$(points)
gmm-acc:
	cd ./runners; make gmm-acc classes=$(classes) points=$(points)
gmm-plot:
	echo "use racket GmmGibbsAccuracy.rkt in output folder for finer control."
	echo "racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 24 --y-max 44 --height 225 --width 400 50 10000 gmm-50-10000.pdf"
	echo "racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 35 --y-max 60 --height 225 --width 400 25 5000 gmm-25-5000.pdf"
	cd ./output; racket GmmGibbsAccuracyPlot.rkt $(classes) $(points) $(output-file)
gmm: gmm-input gmm-trial gmm-acc gmm-plot

gmm-25:
	make gmm-trial classes=25 points=5000
	make gmm-acc classes=25 points=5000
	cd ./output; racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 35 --y-max 60 --height 300 --width 400 25 5000 gmm-25-5000.pdf
# xdg-open ./output/gmm-25-5000.pdf

gmm-50:
	make gmm-trial classes=50 points=10000
	make gmm-acc classes=50 points=10000
	cd ./output; racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 24 --y-max 44 --height 300 --width 400 50 10000 gmm-50-10000.pdf
# xdg-open ./output/gmm-50-10000.pdf

clean-gmm-25:
	rm -f ./output/GmmGibbs/rkt/25-5000
	rm -f ./output/GmmGibbs/augur/25-5000
	rm -f ./output/GmmGibbs/jags/25-5000
	rm -f ./output/GmmGibbs/stan/25-5000
	rm -f ./output/GmmGibbs/accuracies/rkt/25-5000
	rm -f ./output/GmmGibbs/accuracies/augur/25-5000
	rm -f ./output/GmmGibbs/accuracies/jags/25-5000
	rm -f ./output/GmmGibbs/accuracies/stan/25-5000

clean-gmm-50:
	rm -f ./output/GmmGibbs/rkt/50-10000
	rm -f ./output/GmmGibbs/augur/50-10000
	rm -f ./output/GmmGibbs/jags/50-10000
	rm -f ./output/GmmGibbs/stan/50-10000
	rm -f ./output/accuracies/GmmGibbs/rkt/50-10000
	rm -f ./output/accuracies/GmmGibbs/augur/50-10000
	rm -f ./output/accuracies/GmmGibbs/jags/50-10000
	rm -f ./output/accuracies/GmmGibbs/stan/50-10000

# naive bayes
nb:
	mkdir -p output/NaiveBayesGibbs/rkt
	cd ./runners; make nb-rkt trials=2 sweeps=10 trial-time=500 holdout-modulo=10
	mkdir -p ./output/NaiveBayesGibbs/augur
	cd ./runners; make nb-augur trials=12 sweeps=50 trial-time=500 holdout-modulo=10
	mkdir -p ./output/NaiveBayesGibbs/jags
	cd ./runners; make nb-hk
	mkdir -p ./output/accuracies/NaiveBayesGibbs/rkt
	cd ./runners; make nb-rkt-ll holdout-modulo=10
	mkdir -p ./output/accuracies/NaiveBayesGibbs/augur
	cd ./runners; make nb-augur-ll holdout-modulo=10
	mkdir -p ./output/accuracies/NaiveBayesGibbs/jags
	cd ./runners; make nb-jags-ll holdout-modulo=10
	cd ./output; racket NaiveBayesAccuracy.rkt
	cd ./output; racket NaiveBayesLiklihood.rkt

clean-nb:
	rm -f ./output/NaiveBayesGibbs/rkt/20-19997-10
	rm -f ./output/accuracies/NaiveBayesGibbs/rkt/20-19997-10
	rm -f ./output/NaiveBayesGibbs/augur/20-19997-10
	rm -f ./output/accuracies/NaiveBayesGibbs/augur/20-19997-10
	rm -f ./output/NaiveBayesGibbs/jags/20-19997-10
	rm -f ./output/accuracies/NaiveBayesGibbs/jags/20-19997-10

# lda
lda-setup:
	mkdir -p output/LdaGibbs/kos
	mkdir -p output/accuracies/LdaGibbs/kos

lda-50: lda-setup
	cd ./runners; make lda-rkt topics=50 trials=5
	cd ./runners; make lda-augur topics=50 trials=5
	cd ./output; racket LdaLikelihoodPlot.rkt --y-min -4200000 --y-max -4400000 50 ldalikelihood-50.pdf
clean-lda-50:
	rm -f ./output/LdaGibbs/kos/rkt-50
	rm -f ./output/LdaGibbs/kos/augur-50

lda-100: lda-setup
	cd ./runners; make lda-rkt topics=100 trials=5
	cd ./runners; make lda-augur topics=100 trials=2
	cd ./output; racket LdaLikelihoodPlot.rkt --y-min -4500000 --y-max -4700000 100 ldalikelihood-100.pdf
clean-lda-100:
	rm -f ./output/LdaGibbs/kos/rkt-100
	rm -f ./output/LdaGibbs/kos/augur-100

allbench:
	make gmm-25
	make gmm-50
	make nb
	make lda-50
	make lda-100

go:
	make setup
	make allbench

# sham plots
sham-plot:
	cd ./runners/rkt; racket GmmGibbsSham.rkt 25 5000; GmmGibbsOptSham.rkt 25 5000
	cd ./output; racket GmmGibbsTimePlot.rkt
