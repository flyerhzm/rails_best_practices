#!/bin/bash
rubies=( 1.8.7 1.9.2 ree )
for x in ${rubies[*]}
do
  rvm install $x || exit $?
  rvm $x && rvm gemset use global && gem install bundler || exit $?
  bundle install || exit $?
done
