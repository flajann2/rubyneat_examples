# Gemfile for your RubyNEAT RubyneatExamples project.
source 'https://rubygems.org'

gem 'semver'

#gem 'rubyneat'
#gem 'rubyneat_dashboard'
#gem 'rubyneat_rabbitmq'

# During the development
gem 'rubyneat',           github: '/development/ruby_proj/rubyneat',           branch: 'hyper'
gem 'rubyneat_dashboard', github: '/development/ruby_proj/rubyneat_dashboard', branch: 'master'
gem 'rubyneat_rabbitmq',  github: '/development/ruby_proj/rubyneat_rabbitmq',  branch: 'master'

# For demo purposes, we include the gosu library, but if you don't
# need this, then comment it out  or remove it.
# gem 'gosu', require: false

# Well, we may supplant gosu with opengl
gem 'opengl', require: false
gem 'glu', require: false
gem 'glut', require: false
gem 'rubysdl', require: false

# For interfacing with the C++ modules
gem 'ffi'
gem 'rice'

# For reading in ply 3D models
gem 'ply'

group :development do
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'pry-remote'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end
