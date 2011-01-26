#!/bin/bash
rubies=( 1.8.7 1.9.2 ree )
gemset="rails_best_practices"

for x in ${rubies[*]}
do
  rvm use --create $x@$gemset
  bundle install
  rake spec:progress
done
