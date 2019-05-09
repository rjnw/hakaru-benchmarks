.PHONY: psi
stan:
	rm -R cmdstan-2.18.1/
	wget https://github.com/stan-dev/cmdstan/releases/download/v2.18.1/cmdstan-2.18.1.tar.gz
	tar -vkzxf cmdstan-2.18.1.tar.gz
	git checkout cmdstan-2.18.1/

psi:
	cd ./psi; export OSTYPE="linux-gnu"; ./dependencies-release.sh
	cd ./psi; export OSTYPE="linux-gnu"; ./build-release.sh
