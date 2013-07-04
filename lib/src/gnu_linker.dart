part of ccompile;

class GnuLinker implements ProjectTool {
  Async<ProcessResult> run(Project project, [String workingDirectory]) {
    return new Async<ProcessResult>(() {
      Async<ProcessResult> current = Async.current;
      var executable = 'gcc';
      var arguments = _projectToArguments(project);
      var process = Process.run(executable, arguments,
        workingDirectory: workingDirectory);
      new Async.fromFuture(process).then((ProcessResult result) {
        current.result = result;
      });
    });
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.linkerSettings;
    var arguments = [];
    arguments.addAll(settings.arguments);
    if(project.getBits() == 32) {
      arguments.add('-m32');
    }

    var libpaths = SystemUtils.expandEnvironmentVars(settings.libpaths);
    libpaths = libpaths.map((elem) => FileUtils.correctPathSeparators(elem));
    libpaths.forEach((libpath) {
      arguments.add('-L$libpath');
    });

    if(!settings.outputFile.isEmpty) {
      arguments.add('-o');
      arguments.add('${settings.outputFile}');
    }

    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      var ext = new Path(inputFile).extension;
      if(ext.isEmpty) {
        inputFile = '$inputFile.o';
      }
      arguments.add('$inputFile');
    });

    return arguments;
  }
}
