part of ccompile.ccompile;

class MsvcLinker implements ProjectTool {
  ProcessResult run(Project project, [String workingDirectory]) {
  var bits = project.getBits(WindowsUtils.getSystemBits());
  var env = MsvcUtils.getEnvironment(bits);
  Map<String, String> environment = {};
  if(env != null) {
    environment = env;
  }

  var executable = WindowsUtils.findFileInEnvPath(env, 'link.exe');
  var arguments = _projectToArguments(project);
  return Process.runSync(executable, arguments, environment: environment, workingDirectory: workingDirectory);
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
