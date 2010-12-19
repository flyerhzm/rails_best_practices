rails_best_practices
====================

rails_best_practices is a code metric tool to check the quality of rails codes.

Usage
-----

At the root directory of rails app

    rails_best_practices .

notice the period at the end, it can be the relative or absolute path of your rails app.

And default rails_best_practices will do parse codes in vendor, spec, test and features directories. If you need, see the command options:

    $ rails_best_practices -h
    Usage: rails_best_practices [options]
        -d, --debug                      Debug mode
            --vendor                     include vendor files
            --spec                       include spec files
            --test                       include test files
            --features                   include features files
        -x, --exclude PATTERNS           Don't analyze files matching a pattern
                                         (comma-separated regexp list)
        -g, --generate                   Generate configuration yaml
        -v, --version                    Show this version
        -h, --help                       Show this message

Resources
---------

Homepage: <http://rails-bestpractices.com>
Repository: <http://github.com/flyerhzm/rails_best_practices>
Wiki: <http://github.com/flyerhzm/rails_best_practices/wiki>
Issues: <http://github.com/flyerhzm/rails_best_practices/issues>

Install
-------

    gem install rails_best_practices

Issue
-----

If you got NoMethodError or any syntax error, you should use debug mode to detect which file rails_best_practices is parsing and getting the error.

    rails_best_practices -d .

Then give me the error stack and the source code of the file that rails_best_practices is parsing error.

Customize Configuration
-----------------------

First run <code>rails_best_practices -g</code> to generate <code>rails_best_practices.yml</code> file.

Now you can customize this configuration file, the default configuration is as follows:

    MoveFinderToNamedScopeCheck: { }
    UseModelAssociationCheck: { }
    UseScopeAccessCheck: { }
    AddModelVirtualAttributeCheck: { }
    ReplaceComplexCreationWithFactoryMethodCheck: { attribute_assignment_count: 2 }
    MoveModelLogicIntoModelCheck: { use_count: 4 }
    OveruseRouteCustomizationsCheck: { customize_count: 3 }
    NeedlessDeepNestingCheck: { nested_count: 2 }
    NotUseDefaultRouteCheck: {  }
    KeepFindersOnTheirOwnModelCheck: { }
    LawOfDemeterCheck: { }
    UseObserverCheck: { }
    IsolateSeedDataCheck: { }
    AlwaysAddDbIndexCheck: { }
    UseBeforeFilterCheck: { }
    MoveCodeIntoControllerCheck: { }
    MoveCodeIntoModelCheck: { use_count: 2 }
    MoveCodeIntoHelperCheck: { array_count: 3 }
    ReplaceInstanceVariableWithLocalVariableCheck: { }
    DryBundlerInCapistranoCheck: { }
    UseSayWithTimeInMigrationsCheck: { }
    UseQueryAttributeCheck: { }

You can remove or comment one check to disable it, and you can change the options.

Implementation
--------------

* Move code from Controller to Model
1. Move finder to named_scope (rails2 only)
2. Use model association
3. Use scope access
4. Add model virtual attribute
5. Replace Complex Creation with Factory Method
6. Move Model Logic into the Model

* RESTful Conventions
1. Overuse route customizations
2. Needless deep nesting
3. Not use default route

* Model
1. Keep Finders on Their Own Model (rails2 only)
2. the Law of Demeter
3. Use Observer
4. Use Query Attribute

* Migration
1. Isolating Seed Data
2. Always add DB index
3. Use Say with Time in Migrations

* Controller
1. Use before_filter

* View
1. Move code into controller
2. Move code into model
3. Move code into helper
4. Replace instance variable with local variable

* Deployment
1. Dry bundler in capistrano

Contribute
----------

If you want to add your rails best practices into the gem, please post your best practices on <http://rails-bestpractices.com>

Contact Us
----------

Follow us on twitter: <http://twitter.com/railsbp>
Send us email: <team@rails-bestpractices.com>


Copyright © 2010 Richard Huang (flyerhzm@gmail.com), released under the MIT license
