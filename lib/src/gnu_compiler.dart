part of ccompile.ccompile;

class GnuCompiler implements ProjectTool {
  ProcessResult run(Project project, [String workingDirectory]) {
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
}
