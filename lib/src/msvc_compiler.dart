part of ccompile;

class MsvcCompiler implements ProjectTool {
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

        var executable = WindowsUtils.findFileInEnvPath(env, 'cl.exe');
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
    var settings = project.compilerSettings;
    var arguments = ['/c'];
    arguments.addAll(settings.arguments);
    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('"$inputFile"');
    });

    var includes = SystemUtils.expandEnvironmentVars(settings.includes);
    includes = includes.map((elem) => FileUtils.correctPathSeparators(elem));
    includes.forEach((include) {
      arguments.add('/I"$include"');
    });

    settings.defines.forEach((k, v) {
      if(v == null) {
        arguments.add('/D$k');
      } else {
        arguments.add('/D$v=$k');
      }
    });

    return arguments;
  }
}
