.PHONY: setup submodule-init build-hakaru build-rkt build-input clean docker BenchmarkGmmGibbs

setup: submodule-input build-hakaru generate-testcode build-rkt build-input

submodule-init:
	git submodule init
	git submodule update

build-hakaru:
	cd ./hakaru ; stack build && stack install --local-bin-path ../hkbin

generate-testcode:
	cd ./testcode/hkrkt ; make
	cd ./testcode/hksimp ; make
	cd ./testcode/hssrc ; make

build-rkt:
	cd ./rcf; raco pkg install --skip-installed --deps search-auto
	cd ./sham ; raco pkg install --skip-installed --deps search-auto
	cd ./hakrit ; raco pkg install --skip-installed --deps search-auto

build-input:
	cd ./input ; make all

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
	echo "racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 24 --y-max 44 --height 300 --width 400 50 10000 gmm-50-10000.pdf"
	echo "racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 35 --y-max 60 --height 300 --width 400 25 5000 gmm-25-5000.pdf"
	cd ./output; racket GmmGibbsAccuracyPlot.rkt $(classes) $(points) $(output-file)
gmm: gmm-input gmm-trial gmm-acc gmm-plot
gmm-25:
	make gmm-trial classes=25 points=5000
	make gmm-acc classes=25 points=5000
	cd ./output; racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 35 --y-max 60 --height 300 --width 400 25 5000 gmm-25-5000.pdf
	xdg-open ./output/gmm-25-5000.pdf

gmm-50:
	make gmm-trial classes=50 points=10000
	make gmm-acc classes=50 points=10000
	cd ./output; racket GmmGibbsAccuracyPlot.rkt --x-max 20 --y-min 24 --y-max 44 --height 300 --width 400 50 10000 gmm-50-10000.pdf
	xdg-open ./output/gmm-50-10000.pdf

# lda
lda-rkt:
	cd ./runners; make lda-rkt topics=$(topics) trials=$(trials)
lda-augur:
	cd ./runners; make lda-augur topics=$(topics) trials=$(trials)
lda-plot:
	echo "use racket LdaLIkelihoodPlot.rkt in output folder for finer control."
	cd ./output; racket LdaLikelihoodPlot.rkt $(topics) $(output-file)
lda: lda-rkt lda-augur lda-plot

sham-plot:
	cd ./runners/rkt; racket GmmGibbsSham.rkt 25 5000; GmmGibbsOptSham.rkt 25 5000
	cd ./output; racket GmmGibbsTimePlot.rkt
