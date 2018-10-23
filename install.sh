#!/bin/bash

sudo apt-get update

sudo apt-get install -y\
x11-apps \
&& x11-xserver-utils
&& i3

