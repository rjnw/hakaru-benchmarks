#!/bin/sh

sudo docker build . -t hakaru
sudo docker run -it hakaru
