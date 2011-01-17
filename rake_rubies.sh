#!/bin/bash
rubies=( 1.8.7 1.9.2 ree )
gemset="rails_best_practices"

for x in ${rubies[*]}
do
  rvm use --create $x@$gemset && bundle install || exit $?
done
rvm ree@$gemset,1.8.7@$gemset,1.9.2@$gemset rake spec:progress
