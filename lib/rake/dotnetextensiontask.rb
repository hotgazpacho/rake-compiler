require 'rake/baseextensiontask'

# Define a series of tasks to aid in the compilation of .NET extensions for
# gem developer/creators.

module Rake
  class DotNetExtensionTask < BaseExtensionTask

    def init(name = nil, gem_spec = nil)
      super
    end

    def platform
      @platform ||= 'dotnet'
    end
    
    def define_compile_tasks

    end

  end
end
