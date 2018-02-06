var target = Argument("target", "Default");
var package = "DependencyCheck.Runner.Tool";

var apiKey = EnvironmentVariable("NUGET_API_KEY") ?? "abcdef0123456789";
var buildNumber = EnvironmentVariable("APPVEYOR_BUILD_NUMBER") ?? "1";

var version = "3.1.1";
var toolVersion = "3.1.1";

Setup(context =>
{
    if (!DirectoryExists("nuget"))
    {
        CreateDirectory("nuget");
    }
});

Task("Clean")
    .Does(() =>
    {
        CleanDirectory("nuget");
    });

Task("Pack")
    .Does(() =>
    {
        var nuGetPackSettings = new NuGetPackSettings
        {
            Id = package,
            Version = version,
            Title = package,
            Authors = new[] { "Burak İnce" },
            Owners = new[] { "Burak İnce", "cake-contrib" },
            Description = "Nuget tool package for OWASP Dependency Check",
            Summary = "Contains the runner with version " + toolVersion,
            ProjectUrl = new Uri("https://github.com/burakince/DependencyCheck.Runner.Tool"),
            LicenseUrl = new Uri("https://github.com/burakince/DependencyCheck.Runner.Tool/blob/master/LICENSE"),
            RequireLicenseAcceptance = false,
            Symbols = false,
            NoPackageAnalysis = true,
            Files = new [] 
            {
                new NuSpecContent
                {
                    Source = string.Format(@"**", package), Target = "tools"
                }
            },
            BasePath = "./runner",
            OutputDirectory = "./nuget"
        };

        NuGetPack(nuGetPackSettings);
    });

Task("Update-Appveyor-Build-Version")
    .Does(() =>
    {
        if (AppVeyor.IsRunningOnAppVeyor)
        {
            AppVeyor.UpdateBuildVersion(version + string.Concat("+", buildNumber));
        }
        else
        {
            Information("Not running on AppVeyor");
        }
    });

Task("Publish")
    .Does(() =>
    {
        if (string.IsNullOrEmpty(apiKey))
        {
            throw new InvalidOperationException("Could not resolve Nuget API key.");
        };

        var packagePath = "./nuget/" + package + "." + version + ".nupkg";

        NuGetPush(packagePath, new NuGetPushSettings
        {
            Source = "https://www.nuget.org/api/v2/package",
            ApiKey = apiKey
        });
    });

Task("Build")
    .IsDependentOn("Clean")
    .IsDependentOn("Pack")
    .IsDependentOn("Update-Appveyor-Build-Version");

Task("AppVeyor")
    .IsDependentOn("Build")
    .IsDependentOn("Publish");

Task("Default")
    .IsDependentOn("Build");

RunTarget(target);
