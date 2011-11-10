#!/bin/bash
rubies=( 1.9.2-p180 1.9.2-p290 1.9.3-p0 )
gemset="rails_best_practices"

for x in ${rubies[*]}
do
  echo $x@$gemset
  rvm $x@$gemset do bundle exec rake spec:progress
done
