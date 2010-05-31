Feature: Compile .NET extensions

    In order to avod bitching from Enterprisey users
    As a Ruby developer
    I want some Rake tasks that take away the pain of compilation

    @dotnet
    Scenario: Compile single .NET (C#) extension (with default Rake)
        Given that all my C# source files are in place
        And I've installed the .NET Framework
        When rake task 'dotnet compile' is invoked
        Then rake task 'dotnet compile' succeeded
        And binaries for platform 'dotnet' get generated

    @dotnet
    Scenario: Compile single .NET (C#) extension (with Rake on IronRuby)
        Given that all my C# source files are in place
        And I've installed the .NET Framework
        When I've installed IronRuby
        When rake task 'dotnet compile' is invoked
        Then rake task 'dotnet compile' succeeded
        And binaries for platform 'dotnet' get generated       
