part of ccompile.ccompile;

class MsvcLinker implements ProjectTool {
  ProcessResult run(Project project, [String workingDirectory]) {
    var settings = project.linkerSettings;
    var arguments = settings.arguments;
    var libpaths = SystemUtils.expandEnvironmentVars(settings.libpaths);
    libpaths = libpaths.map((elem) => FileUtils.correctPathSeparators(elem));
    var paths = <String>[];
    libpaths.forEach((path) {
      paths.add('$path');
    });

    var output = settings.outputFile;
    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    var input = <String>[];
    inputFiles.forEach((file) {
      var ext = lib_path.extension(file);
      if (ext.isEmpty) {
        file = '$file.obj';
      }

      input.add('$file');
    });

    var bits = project.getBits();
    var linker = new MsLinker(bits: bits, logger: ProjectBuilder.logger);
    return linker.link(input, arguments: arguments, libpaths: paths, output: output, workingDirectory: workingDirectory);
  }

  ProcessResult run_Old(Project project, [String workingDirectory]) {
    var bits = project.getBits(WindowsUtils.getSystemBits());
    var arguments = _projectToArguments(project);
    var linker = new Mslink(bits: bits);
    return linker.run(arguments, workingDirectory: workingDirectory);
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.linkerSettings;
    var arguments = [];
    arguments.addAll(settings.arguments);
    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('$inputFile');
    });

    var libpaths = SystemUtils.expandEnvironmentVars(settings.libpaths);
    libpaths = libpaths.map((elem) => FileUtils.correctPathSeparators(elem));
    libpaths.forEach((libpath) {
      arguments.add('/LIBPATH:$libpath');
    });

    if (!settings.outputFile.isEmpty) {
      arguments.add('/OUT:${settings.outputFile}');
    }

    return arguments;
  }
}
