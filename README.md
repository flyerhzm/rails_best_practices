# rails_best_practices

[![Gem Version](https://badge.fury.io/rb/rails_best_practices.svg)](http://badge.fury.io/rb/rails_best_practices)
[![Build Status](https://secure.travis-ci.org/flyerhzm/rails_best_practices.svg)](http://travis-ci.org/flyerhzm/rails_best_practices)
[![Coverage Status](https://coveralls.io/repos/railsbp/rails_best_practices/badge.svg?branch=master)](https://coveralls.io/r/railsbp/rails_best_practices)
[![AwesomeCode Status for flyerhzm/rails_best_practices](https://awesomecode.io/projects/d02ecd70-e068-4ad4-b61a-7003ac24b49a/status)](https://awesomecode.io/repos/flyerhzm/rails_best_practices)

[![Coderwall Endorse](http://api.coderwall.com/flyerhzm/endorsecount.png)](http://coderwall.com/flyerhzm)
[![Click here to lend your support to: rails best practices and make a donation at www.pledgie.com !](https://pledgie.com/campaigns/12057.png?skin_name=chrome)](https://pledgie.com/campaigns/12057)

rails_best_practices is a code metric tool to check the quality of Rails code.

It supports the following ORM/ODMs:

* activerecord
* mongoid
* mongomapper

And the following template engines:

* erb
* haml
* slim
* rabl

rails_best_practices supports Ruby 1.9.3 or newer.

## External Introduction

[Ruby5 - Episode #253](http://ruby5.envylabs.com/episodes/257-episode-253-march-9th-2012/stories/2253-rails_best_practices)

[Railscasts - #252 Metrics Metrics Metrics](http://railscasts.com/episodes/252-metrics-metrics-metrics)

## Usage

At the root directory of a Rails app, run:

    rails_best_practices .

Or for HTML output:

    rails_best_practices -f html .

By default rails_best_practices will parse code in the `vendor`, `spec`, `test` and `features` directories.

### Excluding directories

To exclude a directory simply call it with `-e` or `--exclude`:

    rails_best_practices -e "db/migrate" .

To exclude multiple directories, separate them with comma:

    rails_best_practices -e "db/migrate,vendor" .

### Other command-line options

To see the full list of command-line options, run:

    $ rails_best_practices -h

    Usage: rails_best_practices [options]
        -d, --debug                      Debug mode
        -f, --format FORMAT              output format
            --without-color              only output plain text without color
            --with-textmate              open file by textmate in html format
            --with-sublime               open file by sublime in html format (requires https://github.com/asuth/subl-handler)
            --with-mvim                  open file by mvim in html format
            --with-github GITHUB_NAME    open file on github in html format. GITHUB_NAME is like railsbp/rails-bestpractices OR full URL to GitHub:FI repo
            --with-hg                    display hg commit and username, only support html format
            --with-git                   display git commit and username, only support html format
            --template TEMPLATE          customize erb template
            --output-file OUTPUT_FILE    output html file for the analyzing result
            --silent                     silent mode
            --vendor                     include vendor files
            --spec                       include spec files
            --test                       include test files
            --features                   include features files
        -x, --exclude PATTERNS           Don't analyze files matching a pattern
                                         (comma-separated regexp list)
        -o, --only PATTERNS              analyze files only matching a pattern
                                         (comma-separated regexp list)
        -g, --generate                   Generate configuration yaml
        -c, --config CONFIG_PATH         configuration file location (defaults to config/rails_best_practices.yml)
        -v, --version                    Show this version
        -h, --help                       Show this message

## Resources

Homepage: <http://rails-bestpractices.com>

GitHub: <http://github.com/railsbp/rails_best_practices>

Team Blog <http://rails-bestpractices.com>

Google Group: <https://groups.google.com/group/rails_best_practices>

Wiki: <http://github.com/railsbp/rails_best_practices/wiki>

Issue Tracker: <http://github.com/railsbp/rails_best_practices/issues>

## Install

    gem install rails_best_practices

or add it to the Gemfile

    gem "rails_best_practices"

#### --with-sublime

Install <https://github.com/asuth/subl-handler>

## Editor Integration

#### TextMate 2

If you use `TextMate 2`, you can install the [RailsBestPractices.tmbundle](https://github.com/jjuliano/RailsBestPractices.tmbundle) bundle.

## Issues

If you install the rails_best_practices with bundler-installed GitHub-sourced gem, please use the following command instead.

    bundle exec rails_best_practices .

If you encounter a NoMethodError exception, or a syntax error, you can use debug mode to discover which file is to blame:

    rails_best_practices -d .

That will provide the error's stack trace and the source code of the file which is causing the error.

## Custom Configuration

First run:

    rails_best_practices -g

to generate `rails_best_practices.yml` file.

Now you can customize this configuration file. The default configuration is as follows:

    AddModelVirtualAttributeCheck: { }
    AlwaysAddDbIndexCheck: { }
    #CheckSaveReturnValueCheck: { }
    #CheckDestroyReturnValueCheck: { }
    DefaultScopeIsEvilCheck: { }
    DryBundlerInCapistranoCheck: { }
    #HashSyntaxCheck: { }
    IsolateSeedDataCheck: { }
    KeepFindersOnTheirOwnModelCheck: { }
    LawOfDemeterCheck: { }
    #LongLineCheck: { max_line_length: 80 }
    MoveCodeIntoControllerCheck: { }
    MoveCodeIntoHelperCheck: { array_count: 3 }
    MoveCodeIntoModelCheck: { use_count: 2 }
    MoveFinderToNamedScopeCheck: { }
    MoveModelLogicIntoModelCheck: { use_count: 4 }
    NeedlessDeepNestingCheck: { nested_count: 2 }
    NotRescueExceptionCheck: { }
    NotUseDefaultRouteCheck: { }
    NotUseTimeAgoInWordsCheck: { }
    OveruseRouteCustomizationsCheck: { customize_count: 3 }
    ProtectMassAssignmentCheck: { }
    RemoveEmptyHelpersCheck: { }
    #RemoveTabCheck: { }
    RemoveTrailingWhitespaceCheck: { }
    RemoveUnusedMethodsInControllersCheck: { except_methods: [] }
    RemoveUnusedMethodsInHelpersCheck: { except_methods: [] }
    RemoveUnusedMethodsInModelsCheck: { except_methods: [] }
    ReplaceComplexCreationWithFactoryMethodCheck: { attribute_assignment_count: 2 }
    ReplaceInstanceVariableWithLocalVariableCheck: { }
    RestrictAutoGeneratedRoutesCheck: { }
    SimplifyRenderInControllersCheck: { }
    SimplifyRenderInViewsCheck: { }
    #UseBeforeFilterCheck: { customize_count: 2 }
    UseModelAssociationCheck: { }
    UseMultipartAlternativeAsContentTypeOfEmailCheck: { }
    UseObserverCheck: { }
    #UseParenthesesInMethodDefCheck: { }
    UseQueryAttributeCheck: { }
    UseSayWithTimeInMigrationsCheck: { }
    UseScopeAccessCheck: { }
    UseTurboSprocketsRails3Check: { }


You can remove or comment a review to disable it, and you can change the options.

You can apply the `ignored_files` option on any rule by giving a regexp or array of regexps describing the path of the files you don't want to be checked:

	DefaultScopeIsEvilCheck: { ignored_files: 'user\.rb' }
	LongLineCheck: { max_line_length: 80, ignored_files: ['db/migrate', 'config/initializers'] }

## Implementation

Move code from Controller to Model

1. Move finder to named_scope (rails2 only)
2. Use model association
3. Use scope access
4. Add model virtual attribute
5. Replace complex creation with factory method
6. Move model logic into the Model
7. Check return value of "save!"

RESTful Conventions

1. Overuse route customizations
2. Needless deep nesting
3. Not use default route
4. Restrict auto-generated routes

Model

1. Keep finders on their own model (rails2 only)
2. The law of demeter
3. Use observer
4. Use query attribute
5. Remove unused methods in models
6. Protect mass assignment
7. Destroy return value (disabled by default)

Mailer

1. Use multipart/alternative as content_type of email

Migration

1. Isolating seed data
2. Always add database index
3. Use say with time in migrations

Controller

1. Use `before_filter` (disabled by default)
2. Simplify render in controllers
3. Remove unused methods in controllers

Helper

1. Remove empty helpers
2. Remove unused methods in helpers

View

1. Move code into controller
2. Move code into model
3. Move code into helper
4. Replace instance variable with local variable
5. Simplify render in views
6. Not use time_ago_in_words

Deployment

1. Dry bundler in Capistrano
2. Speed up assets precompilation with turbo-sprockets-rails3

Other

1. Remove trailing whitespace
2. Remove tab (disabled by default)
3. Hash syntax (disabled by default)
4. Use parentheses in method definition (disabled by default)
5. Long line (disabled by default)
6. Not rescue exception

## Write Your Own Checklist

If you want to write your own checklist (some checklist only for your Rails projects), please read this first, [How to write your own check list?][1]

## Contribute

If you want to add your rails best practices into the gem, please post your best practices on <http://rails-bestpractices.com>

## Contact Us

We provide Rails consulting services, you can contact us by Twitter or email.

Follow us on twitter: <http://twitter.com/railsbp>

Send us email: <team@railsbp.com>


Copyright © 2009 - 2013 Richard Huang (flyerhzm@gmail.com), released under the MIT license


[1]: https://github.com/railsbp/rails_best_practices/wiki/How-to-write-your-own-check-list
