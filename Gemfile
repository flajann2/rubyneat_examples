# Gemfile for your RubyNEAT RubyneatExamples project.
source 'https://rubygems.org'


# For demo purposes, we include the gosu library, but if you don't
# need this, then comment it out  or remove it.
gem 'gosu', require: false

# So you can create pretty charts and graphs of
# your RubyNEAT progress, etc. Feel free to remove
# this if you don't need it.
gem 'rubyvis', require: false

group :development do
  # If this fails, comment this out as the
  # dashboard is still under development.
  # gem 'rubyneat_dashboard'

  # If you are using an IDE, you may wish to remove
  # or replace with the IDE's debugger gem
  # gem 'debugger'
end

#FIXME this should not be necessary here.
gem 'semver'

unless ENV['IDE_DEBUGGER']
  puts '<<<Running from Command Line>>>'
  gem 'rubyneat'

  # So we can have a dashboard to monitor and control the
  # progress of RubyNEAT
  gem 'rubyneat_dashboard'
else
  puts '<<<Running in IDE Debugger so we can debug the RubyNEAT Gems.>>>'
  ################################################################
  ################################################################
  ################################################################
  # TODO: Debugging only -- remove all below

  gem 'distribution'#, '~> 0'
  gem 'statistics2'#, '~> 0'
  gem 'debase'#, '~> 0'
  gem 'aquarium'#, '~> 0'
  gem 'thor'#, '~> 0'
  gem 'awesome_print'#, '~> 1'
  gem 'deep_dive'
  gem 'queue_ding'
  gem 'bond', '~> 0'
  gem 'rb-readline'#, '~> 0'
  group :development do
    gem 'rspec', '~> 2'
    gem 'yard', '~> 0'
    gem 'guard', '~> 2'
    gem 'guard-rspec', '~> 4'
    gem 'simplecov'
  end

  gem 'sinatra'#, '~> 1'
  gem 'thin'
  gem 'haml'#, '~> 4'
  gem 'sass'#, '~> 3'
  gem 'json'#, '~> 1'
  gem 'json-stream'#, '~> 0'
  gem 'compass'
  gem 'barista'
  gem 'sinatra-assetpack'
  gem 'eventmachine'

  gem 'sinatra-contrib'

  group :development do
    gem "rdoc", "~> 3"
    gem "bundler", "~> 1"
  end
end
