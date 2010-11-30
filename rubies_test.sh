#!/bin/bash
rvm ruby-1.8.7@rails_best_practices ruby -S bundle install      || exit $?
rvm ruby-1.9.2@rails_best_practices ruby -S bundle install      || exit $?
rvm ree@rails_best_practices ruby -S bundle install             || exit $?
rvm 1.8.7@rails_best_practices
rake spec:progress
rvm 1.9.2@rails_best_practices
rake spec:progress
rvm ree@rails_best_practices
rake spec:progress
