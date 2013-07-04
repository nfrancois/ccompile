part of ccompile;

class MsvcLinker implements ProjectTool {
  Async<ProcessResult> run(Project project, [String workingDirectory]) {
    return new Async<ProcessResult>(() {
      Async<ProcessResult> current = Async.current;
      var bits = project.getBits(WindowsUtils.getSystemBits());
      MsvcUtils.getEnvironment(bits)
      .then((env) {
        Map<String, String> environment = {};
        if(env != null) {
          environment = env;
        }

        var executable = WindowsUtils.findFileInEnvPath(env, 'link.exe');
        var arguments = _projectToArguments(project);
        var process = Process.run(executable, arguments,
          environment: environment, workingDirectory: workingDirectory);
        new Async.fromFuture(process)
        .then((ProcessResult result) {
          current.result = result;
        });
      });
    });
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.linkerSettings;
    var arguments = [];
    arguments.addAll(settings.arguments);
    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('"$inputFile"');
    });

    var libpaths = SystemUtils.expandEnvironmentVars(settings.libpaths);
    libpaths = libpaths.map((elem) => FileUtils.correctPathSeparators(elem));
    libpaths.forEach((libpath) {
      arguments.add('/LIBPATH:"$libpath"');
    });

    if(!settings.outputFile.isEmpty) {
      arguments.add('/OUT:"${settings.outputFile}"');
    }

    return arguments;
  }
}
