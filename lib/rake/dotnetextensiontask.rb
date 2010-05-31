require 'rake/baseextensiontask'

# Define a series of tasks to aid in the compilation of .NET extensions for
# gem developer/creators.

module Rake
  class DotNetExtensionTask < BaseExtensionTask

    def init(name = nil, gem_spec = nil)
      super
      @source_pattern = '**/*.cs'
    end

    def platform
      @platform ||= 'dotnet'
    end
   
    private
    def define_compile_tasks(for_platform = nil, ruby_ver = RUBY_VERSION)
      # platform usage
      platf = for_platform || platform

      # lib_path
      lib_path = lib_dir

      # tmp_path
      tmp_path = "#{@tmp_dir}/#{platf}/#{@name}"

      # cleanup and clobbering
      CLEAN.include(tmp_path)
      CLOBBER.include("#{lib_path}/#{binary(platf)}")
      CLOBBER.include("#{@tmp_dir}")

      task "copy" do

      end

      # copy binary from temporary location to final lib
      # tmp/extension_name/extension_name.{so,bundle} => lib/
      task "copy:#{@name}:#{platf}" => [lib_path, "#{tmp_path}/#{binary(platf)}"] do
        cp "#{tmp_path}/#{binary(platf)}", "#{lib_path}/#{binary(platf)}"
      end

      # compile tasks
      unless Rake::Task.task_defined?('compile') then
        desc "Compile all the extensions"
        task "compile" => ["compile:#{platf}"]
      end

      # compile:name
      unless Rake::Task.task_defined?("compile:#{@name}") then
        desc "Compile #{@name}"
        task "compile:#{@name}" => ["compile:extension_one:#{platf}"]
      end

      # Allow segmented compilation by platform (open door for 'cross compile')
      task "compile:#{@name}:#{platf}" => ["copy:#{@name}:#{platf}"]
      task "compile:#{platf}" => ["compile:#{@name}:#{platf}"]

      file "#{tmp_path}/.build" => [tmp_path] + source_files do

      end

      file "#{tmp_path}/#{binary(platf)}" => "#{tmp_path}/.build" do

      end

      file "#{lib_path}/#{binary(platf)}" => ["copy:#{@name}:#{platf}"] do
        
      end

    end
  end
end
