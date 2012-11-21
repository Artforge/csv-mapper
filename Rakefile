require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rgarner-csv-mapper"
    gem.summary = %Q{rgarner-CsvMapper is a fork of a small library intended to simplify the common steps involved with importing CSV files to a usable form in Ruby. It has support for null column names. When this is merged, this gem will be removed.}
    gem.description = %Q{CSV Mapper makes it easy to import data from CSV files directly to a collection of any type of Ruby object. The simplest way to create mappings is declare the names of the attributes in the order corresponding to the CSV file column order.}
    gem.email = "rgarner@zephyros-systems.co.uk"
    gem.homepage = "http://github.com/rgarner/csv-mapper"
    gem.authors = ["Luke Pillow", "Russell Garner"]
    gem.add_development_dependency "rspec", ">= 2.0.0"
    gem.add_dependency "fastercsv"  
    gem.extra_rdoc_files << "History.txt"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rgarner-csv-mapper #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
