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

   def mock_gem_spec(stubs = {})
    mock(Gem::Specification,
      { :name => 'my_gem', :platform => 'ruby' }.merge(stubs)
    )
  end
end
