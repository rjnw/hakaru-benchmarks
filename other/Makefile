.PHONY: psi
stan:
	wget https://github.com/stan-dev/cmdstan/releases/download/v2.18.1/cmdstan-2.18.1.tar.gz
	tar -vkzxf cmdstan-2.18.1.tar.gz

psi:
	cd ./psi; export OSTYPE="linux-gnu"; ./dependencies-release.sh
	cd ./psi; export OSTYPE="linux-gnu"; ./build-release.sh
