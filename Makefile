.PHONY setup initSubmodules generateTestCode installRktPkg runtests benchmark

setup: initSubmodules setupHakaru generateTestCode installRktPkg

setupHakaru:
	cd ./hakaru ; stack build && stack install --local-bin-path ../hkbin

initSubmodules:
	git submodule init
	git submodule update

generateTestCode:
	cd ./testcode/hkrkt ; make
	cd ./testcode/hksimp ; make
	cd ./testcode/hssrc ; make

installRktPkg:
	cd ./sham ; raco pkg install
	cd ./hakrit ; raco pkg install

clean:
	cd ./hakaru; stack clean
	rm ./hkbin/*
	cd ./testcode/hkrkt ; make clean
	cd ./testcode/hksimp ; make clean
	cd ./testcode/hssrc ; make clean

runtests:
	echo "TODO runtests :P"

benchmark: runtests
	echo "We can't even run yet how do we benchmark??"
