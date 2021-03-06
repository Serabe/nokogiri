# -*- ruby -*-

require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'

windows = RUBY_PLATFORM =~ /(mswin|mingw)/i
java    = RUBY_PLATFORM =~ /java/

GENERATED_PARSER    = "lib/nokogiri/css/generated_parser.rb"
GENERATED_TOKENIZER = "lib/nokogiri/css/generated_tokenizer.rb"

EXTERNAL_JAVA_LIBRARIES = %w{isorelax jing nekohtml xercesImpl}.map{|x| "lib/#{x}.jar"}
JAVA_EXT = "lib/nokogiri/nokogiri.jar"
JRUBY_HOME = Config::CONFIG['prefix']

require 'nokogiri/version'

# Make sure hoe-debugging is installed
Hoe.plugin :debugging

HOE = Hoe.spec 'nokogiri' do
  developer('Aaron Patterson', 'aaronp@rubyforge.org')
  developer('Mike Dalessio', 'mike.dalessio@gmail.com')
  self.readme_file   = ['README', ENV['HLANG'], 'rdoc'].compact.join('.')
  self.history_file  = ['CHANGELOG', ENV['HLANG'], 'rdoc'].compact.join('.')
  self.extra_rdoc_files  = FileList['*.rdoc']
  self.clean_globs = [
    'lib/nokogiri/*.{o,so,bundle,a,log,dll}',
    GENERATED_PARSER,
    GENERATED_TOKENIZER,
    'cross',
  ]

  %w{ racc rexical rake-compiler }.each do |dep|
    self.extra_dev_deps << dep
  end

  self.spec_extras = { :extensions => ["ext/nokogiri/extconf.rb"] }
end

Rake::RDocTask.new('AWESOME') do |rd|
  rd.main = HOE.readme_file
  rd.options << '-d' if (`which dot` =~ /\/dot/) unless
  rd.rdoc_dir = 'doc'

  rd.rdoc_files += HOE.spec.require_paths
  rd.rdoc_files += HOE.spec.extra_rdoc_files

  title = HOE.spec.rdoc_options.grep(/^(-t|--title)=?$/).first

  if title then
    rd.options << title

    unless title =~ /=/ then # for ['-t', 'title here']
      title_index = HOE.spec.rdoc_options.index(title)
      rd.options << HOE.spec.rdoc_options[title_index + 1]
    end
  else
    title = "#{HOE.name}-#{HOE.version} Documentation"
    title = "#{HOE.rubyforge_name}'s " + title if HOE.rubyforge_name != HOE.name
    rd.options << '--title' << title
  end
end

unless java
  gem 'rake-compiler', '>= 0.4.1'
  require "rake/extensiontask"

  RET = Rake::ExtensionTask.new("nokogiri", HOE.spec) do |ext|
    ext.lib_dir = File.join(*['lib', 'nokogiri', ENV['FAT_DIR']].compact)

    ext.config_options << ENV['EXTOPTS']
    cross_dir = File.join(File.dirname(__FILE__), 'tmp', 'cross')
    ext.cross_compile   = true
    ext.cross_platform  = 'i386-mingw32'
    ext.cross_config_options <<
      "--with-iconv-dir=#{File.join(cross_dir, 'iconv')}"
    ext.cross_config_options <<
      "--with-xml2-dir=#{File.join(cross_dir, 'libxml2')}"
    ext.cross_config_options <<
      "--with-xslt-dir=#{File.join(cross_dir, 'libxslt')}"
  end

  file 'lib/nokogiri/nokogiri.rb' do
    File.open("lib/#{HOE.name}/#{HOE.name}.rb", 'wb') do |f|
      f.write <<-eoruby
require "#{HOE.name}/\#{RUBY_VERSION.sub(/\\.\\d+$/, '')}/#{HOE.name}"
      eoruby
    end
  end

  namespace :cross do
    task :file_list do
      HOE.spec.platform = 'x86-mingw32'
      HOE.spec.extensions = []
      HOE.spec.files += Dir["lib/#{HOE.name}/#{HOE.name}.rb"]
      HOE.spec.files += Dir["lib/#{HOE.name}/1.{8,9}/#{HOE.name}.so"]
      HOE.spec.files += Dir["ext/nokogiri/*.dll"]
    end
  end

  CLOBBER.include("lib/nokogiri/nokogiri.{so,dylib,rb,bundle}")
  CLOBBER.include("lib/nokogiri/1.{8,9}")
  CLOBBER.include("ext/nokogiri/*.dll")
end

namespace :java do

  desc "Removes all generated during compilation .class files."
  task :clean_classes do
    (FileList['ext/java/nokogiri/internals/*.class'] + FileList['ext/java/nokogiri/*.class'] + FileList['ext/java/*.class']).to_a.each do |file|
      File.delete file
    end
  end

  desc "Removes the generated .jar"
  task :clean_jar do
    FileList['lib/nokogiri/*.jar'].each{|f| File.delete f }
  end

  desc  "Same as java:clean_classes and java:clean_jar"
  task :clean_all => ["java:clean_classes", "java:clean_jar"]
  
  desc "Build a gem targetted for JRuby"
  task :gem => ['java:spec'] do
    system "gem build nokogiri.gemspec"
    FileUtils.mkdir_p "pkg"
    FileUtils.mv Dir.glob("nokogiri*-java.gem"), "pkg"
  end

  task :spec => [GENERATED_PARSER, GENERATED_TOKENIZER, :build] do
    File.open("#{HOE.name}.gemspec", 'w') do |f|
      HOE.spec.platform = 'java'
      HOE.spec.files += [GENERATED_PARSER, GENERATED_TOKENIZER, JAVA_EXT] + EXTERNAL_JAVA_LIBRARIES
      HOE.spec.extensions = []
      f.write(HOE.spec.to_ruby)
	  end
  end

  task :spec => ['gem:dev:spec']

  desc "Build external library"
  task :build_external do
    Dir.chdir('ext/java') do
      LIB_DIR = '../../lib'
      CLASSPATH = "#{JRUBY_HOME}/lib/jruby.jar:#{LIB_DIR}/nekohtml.jar:#{LIB_DIR}/xercesImpl.jar:#{LIB_DIR}/isorelax.jar:#{LIB_DIR}/jing.jar"
      sh "javac -cp #{CLASSPATH} nokogiri/*.java nokogiri/internals/*.java"
      sh "jar cf ../../#{JAVA_EXT} nokogiri/*.class nokogiri/internals/*.class"
    end
  end

  task :build => ["java:clean_jar", "java:build_external", "java:clean_classes"]
end

namespace :gem do
  namespace :dev do
    task :spec do
      File.open("#{HOE.name}.gemspec", 'w') do |f|
        HOE.spec.version = "#{HOE.version}.#{Time.now.strftime("%Y%m%d%H%M%S")}"
        f.write(HOE.spec.to_ruby)
      end
    end
  end

  desc "Build a gem targetted for JRuby (FFI version)"
  task :jruby => ['gem:jruby:spec'] do
    system "gem build nokogiri.gemspec"
    FileUtils.mkdir_p "pkg"
    FileUtils.mv Dir.glob("nokogiri*-java.gem"), "pkg"
  end

  namespace :jruby do
    task :spec => [GENERATED_PARSER, GENERATED_TOKENIZER] do
      File.open("#{HOE.name}.gemspec", 'w') do |f|
        HOE.spec.platform = 'java'
        HOE.spec.files << GENERATED_PARSER
        HOE.spec.files << GENERATED_TOKENIZER
        HOE.spec.files += Dir["ext/nokogiri/*.dll"]
        HOE.spec.extensions = []
        f.write(HOE.spec.to_ruby)
      end
    end
  end


  task :spec => ['gem:dev:spec']
end

file GENERATED_PARSER => "lib/nokogiri/css/parser.y" do |t|
  begin
    racc = `which racc`.strip
    racc = "#{::Config::CONFIG['bindir']}/racc" if racc.empty?
    sh "#{racc} -l -o #{t.name} #{t.prerequisites.first}"
  rescue
    abort "need racc, sudo gem install racc"
  end
end

file GENERATED_TOKENIZER => "lib/nokogiri/css/tokenizer.rex" do |t|
  begin
    sh "rex --independent -o #{t.name} #{t.prerequisites.first}"
  rescue
    abort "need rexical, sudo gem install rexical"
  end
end

#task :build => [JAVA_EXT, GENERATED_PARSER, GENERATED_TOKENIZER]

libs = %w{
  iconv-1.9.2.win32
  zlib-1.2.3.win32
  libxml2-2.7.3.win32
  libxslt-1.1.24.win32
}

lib_dlls = {
  'iconv-1.9.2.win32'     => 'iconv.dll',
  'zlib-1.2.3.win32'      => 'zlib1.dll',
  'libxml2-2.7.3.win32'   => 'libxml2.dll',
  'libxslt-1.1.24.win32'  => 'libxslt.dll',
}

libs.each do |lib|
  libname = lib.split('-').first

  file "tmp/stash/#{lib}.zip" do |t|
    puts "downloading #{lib}"
    FileUtils.mkdir_p('tmp/stash')
    Dir.chdir('tmp/stash') do
      url = "ftp://ftp.xmlsoft.org/libxml2/win32/#{lib}.zip"
      system("wget #{url} || curl -O #{url}")
    end
  end

  file "tmp/cross/#{libname}" => ["tmp/stash/#{lib}.zip"] do |t|
    puts "unzipping #{lib}.zip"
    FileUtils.mkdir_p('tmp/cross')
    Dir.chdir('tmp/cross') do
      sh "unzip ../stash/#{lib}.zip"
      sh "cp #{lib}/bin/* #{lib}/lib" # put DLL in lib, so dirconfig works
      sh "mv #{lib} #{lib.split('-').first}"
      sh "touch #{lib.split('-').first}"
    end
  end

  file "ext/nokogiri/#{lib_dlls[lib]}" => "tmp/cross/#{libname}" do |t|
    Dir.chdir('tmp/cross') do
      sh "cp #{libname}/bin/*.dll ../../ext/nokogiri/"
    end
  end

  if Rake::Task.task_defined?(:cross)
    Rake::Task[:cross].prerequisites << "ext/nokogiri/#{lib_dlls[lib]}"
    Rake::Task[:cross].prerequisites << "lib/nokogiri/nokogiri.rb"
    Rake::Task[:cross].prerequisites << "cross:file_list"
  end
  Rake::Task['gem:jruby:spec'].prerequisites << "ext/nokogiri/#{lib_dlls[lib]}"
end

require 'tasks/test'

desc "set environment variables to build and/or test with debug options"
task :debug do
  ENV['NOKOGIRI_DEBUG'] = "true"
  ENV['CFLAGS'] ||= ""
  ENV['CFLAGS'] += " -DDEBUG"
end

# required_ruby_version

# Only do this on unix, since we can't build on windows
unless windows || java || ENV['NOKOGIRI_FFI']
  [:compile, :check_manifest].each do |task_name|
    Rake::Task[task_name].prerequisites << GENERATED_PARSER
    Rake::Task[task_name].prerequisites << GENERATED_TOKENIZER
  end

  Rake::Task[:test].prerequisites << :compile
  if Hoe.plugins.include?(:debugging)
    ['valgrind', 'valgrind:mem', 'valgrind:mem0'].each do |task_name|
      Rake::Task["test:#{task_name}"].prerequisites << :compile
    end
  end
else
  [:test, :check_manifest].each do |task_name|
    if Rake::Task[task_name]
      Rake::Task[task_name].prerequisites << GENERATED_PARSER
      Rake::Task[task_name].prerequisites << GENERATED_TOKENIZER
    end
  end
end

namespace :install do
  desc "Install rex and racc for development"
  task :deps => %w(rexical racc)

  task :racc do |t|
    sh "sudo gem install racc"
  end

  task :rexical do
    sh "sudo gem install rexical"
  end
end

# vim: syntax=Ruby
