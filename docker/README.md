# Docker commands :smile:
* :star: Build  `docker build . -t benchmarks`
* :runner: Run `docker run -it benchmark`
* :alien: To share directory `docker run -v $(pwd)/..:/root/hb -it benchmark`

Running a continer will always create a new one,
but the older one is still saved, paused with its state. :open_mouth:

To run it again:
* List all containers `docker container ls -a`
* Get the name or id of container from the list:
* * Start  `docker start <name>` :grin:
* * Attach `docker attach <name>` :satisfied:

## Cleaning up :fire:
* Remove all the containers `docker rm $(docker ps -a -q)` :boom:
* Prune dangling images `docker image prune`  :sparkles:
* Removing image `docker rmi <image>` you can list all the images by `docker images` :smiley_cat: