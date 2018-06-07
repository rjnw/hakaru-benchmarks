# Docker commands :smile:
* :star: Build  `docker build . -t benchmarks`
* :runner: Run `docker run -it benchmark`
* :alien: To share directory `docker run -v $(pwd)/..:/root/hb -it benchmark`
* To set a specific mac address(for reusing maple license) --mac-address
* To copy files out of a container `docker cp <container-id>:<docker-path> <host-path>`

Running a continer will always create a new one,
but the older one is still saved, paused with its state. :open_mouth:

To run it again:
* List all containers `docker container ls -a`
* Get the name or id of container from the list:
* * Start  `docker start <name>` :grin:
* * Attach `docker attach <name>` :satisfied:

Sharing containers
* export `docker export <container-id> | gzip > filename.tar.gz`
** `docker export --output="filename.tar.gz" <container-id>`
* import `gzcat filename.tar.gz | docker import - <container-name>
** `docker import <file-name/url> <image-name>
** running imported image `docker run --entrypoint "/init.sh" --mac-address <mac> -it <image-name>`

Sharing images

## Cleaning up :fire:
* Remove all the containers `docker rm $(docker ps -a -q)` :boom:
* Prune dangling images `docker image prune`  :sparkles:
* Removing image `docker rmi <image>` you can list all the images by `docker images` :smiley_cat: