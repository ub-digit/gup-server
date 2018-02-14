#!/bin/bash

PATH=$PATH:/usr/local/bin
. /usr/local/rvm/scripts/rvm

DIR=/apps/gup-server/current
cd $DIR
rvm use 2.3.1
RAILS_ENV=$2 bundle exec rake "$1"
