Given /^I've installed the \.NET Framework$/ do
  pending('Cannot locate a suitable C# compiler in the PATH') unless search_path(%w(csc csc.exe))
end

When /^I've installed IronRuby$/ do
  pending('Cannot locate an IronRuby installation in the PATH') unless search_path(%w(ir ir.exe))
end

