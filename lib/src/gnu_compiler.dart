part of ccompile.ccompile;

class GnuCompiler implements ProjectTool {
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

    int bits;
    if (_canUseM32M64Option()) {
      if (project.getBits() == 32) {
        bits = 32;
      } else if (project.getBits() == 64) {
        bits = 64;
      }
    }

    var executable = project.compilerSettings.getExecutable('g++');
    if (executable == 'g++') {
      var compiler = new GnuCppCompiler(bits: bits, logger: ProjectBuilder.logger);
      return compiler.compile(input, arguments: arguments, define: define, include: include, workingDirectory: workingDirectory);
    } else if (executable == 'gcc') {
      var compiler = new GnuCCompiler(bits: bits, logger: ProjectBuilder.logger);
      return compiler.compile(input, arguments: arguments, define: define, include: include, workingDirectory: workingDirectory);
    } else {
      throw new StateError('Unsupported compiler executable $executable');
    }
  }

  ProcessResult run_Old(Project project, [String workingDirectory]) {
    var executable = project.compilerSettings.getExecutable('g++');
    var arguments = _projectToArguments(project);
    var compiler;
    if (executable == 'g++') {
      compiler = new Gpp();
    } else if (executable == 'gcc') {
      compiler = new Gcc();
    } else {
      throw new StateError('Unsupported compiler executable $executable');
    }

    return compiler.run(arguments, workingDirectory: workingDirectory);
  }

  bool _canUseM32M64Option() {
    switch (Platform.operatingSystem) {
      case "linux":
        var file = new File("/proc/cpuinfo");
        if (!file.existsSync()) {
          return true;
        }

        var cpuinfo = file.readAsStringSync();
        return !cpuinfo.contains("CPU implementer");
      default:
        return true;
    }
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.compilerSettings;
    var arguments = ['-c'];
    arguments.addAll(settings.arguments);
    if (_canUseM32M64Option()) {
      if (project.getBits() == 32) {
        arguments.add('-m32');
      } else if (project.getBits() == 64) {
        arguments.add('-m64');
      }
    }

    var includes = SystemUtils.expandEnvironmentVars(settings.includes);
    includes = includes.map((elem) => FileUtils.correctPathSeparators(elem));
    includes.forEach((include) {
      arguments.add('-I$include');
    });

    settings.defines.forEach((k, v) {
      if (v == null) {
        arguments.add('-D$k');
      } else {
        arguments.add('-D$v=$k');
      }
    });

    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('$inputFile');
    });

    return arguments;
  }
}
