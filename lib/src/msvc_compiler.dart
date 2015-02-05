part of ccompile.ccompile;

class MsvcCompiler implements ProjectTool {
  ProcessResult run(Project project, [String workingDirectory]) {
    var settings = project.compilerSettings;
    var arguments = settings.arguments;
    var define = settings.defines;
    var includes = SystemUtils.expandEnvironmentVars(settings.includes);
    includes = includes.map((elem) => FileUtils.correctPathSeparators(elem));
    var include = <String>[];
    includes.forEach((file) {
      include.add('$file');
    });

    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    var input = <String>[];
    inputFiles.forEach((file) {
      input.add('$file');
    });

    var bits = project.getBits();
    var compiler = new lib_ccompilers.MsCppCompiler(bits: bits, logger: ProjectBuilder.logger);
    return compiler.compile(input, arguments: arguments, define: define, include: include, workingDirectory: workingDirectory);
  }

  ProcessResult run_old(Project project, [String workingDirectory]) {
    var bits = project.getBits(WindowsUtils.getSystemBits());
    var arguments = _projectToArguments(project);
    var compiler = new Msvc(bits: bits);
    return compiler.run(arguments, workingDirectory: workingDirectory);
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.compilerSettings;
    var arguments = ['/c'];
    arguments.addAll(settings.arguments);
    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('$inputFile');
    });

    var includes = SystemUtils.expandEnvironmentVars(settings.includes);
    includes = includes.map((elem) => FileUtils.correctPathSeparators(elem));
    includes.forEach((include) {
      arguments.add('/I"$include"');
    });

    settings.defines.forEach((k, v) {
      if (v == null) {
        arguments.add('/D$k');
      } else {
        arguments.add('/D$v=$k');
      }
    });

    return arguments;
  }
}
