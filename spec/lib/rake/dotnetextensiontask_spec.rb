require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'rake/dotnetextensiontask'
require 'rbconfig'

describe Rake::DotNetExtensionTask do
  context '#new' do
    context '(basic)' do
      it 'should raise an error if no name is provided' do
        lambda {
          Rake::DotNetExtensionTask.new
        }.should raise_error(RuntimeError, /Extension name must be provided/)
      end

      it 'should allow string as extension name assignation' do
        ext = Rake::DotNetExtensionTask.new('extension_one')
        ext.name.should == 'extension_one'
      end

      it 'should allow string as extension name using block assignation' do
        ext = Rake::DotNetExtensionTask.new do |ext|
          ext.name = 'extension_two'
        end
        ext.name.should == 'extension_two'
      end

      it 'should return itself for the block' do
        from_block = nil
        from_lasgn = Rake::DotNetExtensionTask.new('extension_three') do |ext|
          from_block = ext
        end
        from_block.should == from_lasgn
      end

      it 'should accept a gem specification as parameter' do
        spec = mock_gem_spec
        ext = Rake::DotNetExtensionTask.new('extension_three', spec)
        ext.gem_spec.should == spec
      end

      it 'should allow gem specification be defined using block assignation' do
        spec = mock_gem_spec
        ext = Rake::DotNetExtensionTask.new('extension_four') do |ext|
          ext.gem_spec = spec
        end
        ext.gem_spec.should == spec
      end

      it 'should allow forcing of platform' do
        ext = Rake::DotNetExtensionTask.new('weird_extension') do |ext|
          ext.platform = 'dotnet-128bit'
        end
        ext.platform.should == 'dotnet-128bit'
      end
    end
  end

  context '(default)' do
    before :each do
      @ext = Rake::DotNetExtensionTask.new('extension_one')
    end

    it 'should dump intermediate files to tmp/' do
      @ext.tmp_dir.should == 'tmp'
    end

    it 'should copy build extension into lib/' do
      @ext.lib_dir.should == 'lib'
    end

    it 'should look for C# files pattern (.cs)' do
      @ext.source_pattern.should == "**/*.cs"
    end

    it 'should have no configuration options preset to delegate' do
      @ext.config_options.should be_empty
    end

    it 'should default to .NET platform' do
      @ext.platform.should == 'dotnet'
    end

    context '(tasks)' do
      before :each do
        Rake.application.clear
        CLEAN.clear
        CLOBBER.clear
      end

      context '(one extension)' do
        before :each do
          Rake::FileList.stub!(:[]).and_return(["ext/extension_one/source.cs"])
          @ext = Rake::DotNetExtensionTask.new('extension_one')
          @ext_bin = ext_bin('extension_one')
          @platform = 'dotnet'
        end

        context 'copy' do
          it 'should define as task' do
            Rake::Task.task_defined?('copy').should be_true
          end
        end

        context 'compile' do
          it 'should define as task' do
            Rake::Task.task_defined?('compile').should be_true
          end

          it "should depend on 'compile:{platform}'" do
            Rake::Task['compile'].prerequisites.should include("compile:#{@platform}")
          end
        end

        context 'compile:extension_one' do
          it 'should define as task' do
            Rake::Task.task_defined?('compile:extension_one').should be_true
          end

          it "should depend on 'compile:extension_one:{platform}'" do
            Rake::Task['compile:extension_one'].prerequisites.should include("compile:extension_one:#{@platform}")
          end
        end

        context 'lib/extension_one.dll' do
          it 'should define as task' do
            Rake::Task.task_defined?("lib/#{@ext_bin}").should be_true
          end

          it "should depend on 'copy:extension_one:{platform}'" do
            Rake::Task["lib/#{@ext_bin}"].prerequisites.should include("copy:extension_one:#{@platform}")
          end
        end

        context 'tmp/{platform}/extension_one/extension_one.dll' do
          it 'should define as task' do
            Rake::Task.task_defined?("tmp/#{@platform}/extension_one/#{@ext_bin}").should be_true
          end

          it "should depend on checkpoint file" do
            Rake::Task["tmp/#{@platform}/extension_one/#{@ext_bin}"].prerequisites.should include("tmp/#{@platform}/extension_one/.build")
          end
        end

        context 'tmp/{platform}/extension_one/.build' do
          it 'should define as task' do
            Rake::Task.task_defined?("tmp/#{@platform}/extension_one/.build").should be_true
          end

          it 'should depend on source files' do
            Rake::Task["tmp/#{@platform}/extension_one/.build"].prerequisites.should include("ext/extension_one/source.cs")
          end
        end

        context 'clean' do
          it "should include 'tmp/{platform}/extension_one' in the pattern" do
            CLEAN.should include("tmp/#{@platform}/extension_one")
          end
        end

        context 'clobber' do
          it "should include 'lib/extension_one.dll'" do
            CLOBBER.should include("lib/#{@ext_bin}")
          end

          it "should include 'tmp'" do
            CLOBBER.should include('tmp')
          end
        end

      end
    end
  end

  private
  def ext_bin(extension_name)
    "#{extension_name}.dll"
  end

  def mock_gem_spec(stubs = {})
    mock(Gem::Specification,
      { :name => 'my_gem', :platform => 'ruby' }.merge(stubs)
    )
  end
end
