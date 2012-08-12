#!/bin/bash
rubies=( 1.9.2 1.9.3 )
gemset="rails_best_practices"

for x in ${rubies[*]}
do
  rvm install $x
  rvm $x && rvm gemset use global && gem install bundler
  rvm --create $x@$gemset do bundle install
done
