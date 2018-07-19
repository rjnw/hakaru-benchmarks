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

gmm-trial:
	cd ./runners; make gmm-trial classes=$(classes) points=$(points)
gmm-acc:
	cd ./runners; make gmm-acc classes=$(classes) points=$(points)
gmm-plot:
	echo "use racket GmmGibbsAccuracy.rkt in output folder for finer control."
	cd ./output; racket GmmGibbsAccuracy.rkt $(classes) $(points) $(output-file)

gmm: gmm-trial gmm-acc gmm-plot

BenchmarkGmmGibbs:
