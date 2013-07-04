part of ccompile;

class ProjectBuilder {
  String _platform;

  ProjectBuilder() {
    _platform = Platform.operatingSystem;
  }

  Async<ProcessResult> build(Project project, [String workingDirectory]) {
    return compile(project, workingDirectory).then((result) {
      Async<ProcessResult> current = Async.current;
      if(result.exitCode != 0) {
        return result;
      }

      link(project, workingDirectory)
      .then((result) {
        current.result = result;
      });
    });
  }

  Async<ProcessResult> compile(Project project, [String workingDirectory]) {
    return getCompiler().run(project, workingDirectory);
  }

  Async<ProcessResult> link(Project project, [String workingDirectory]) {
    return getLinker().run(project, workingDirectory);
  }

  Async<ProcessResult> clean(Project project, [String workingDirectory]) {
    return getCleaner().run(project, workingDirectory);
  }

  Async<ProcessResult> buildAndClean(Project project, [String workingDirectory]) {
    return build(project, workingDirectory).then((result) {
      Async<ProcessResult> current = Async.current;
      clean(project, workingDirectory)
      .then((unused) {
        current.result = result;
      });
    });
  }

  Async<ProcessResult> customBuild(Project project, [String workingDirectory,
    bool compile = true, link = true, clean = true]) {
    return new Async<ProcessResult>(() {
      Async<ProcessResult> current = Async.current;
      if(!compile) {
        return new ProjectToolResult();
      }

      this.compile(project, workingDirectory)
      .then((ProcessResult result) {
        if(result.exitCode != 0 || !link) {
          current.result = result;
          return;
        }

        this.link(project, workingDirectory)
        .then((ProcessResult result) {
          if(!clean) {
            current.result = result;
            return;
          }

          this.clean(project, workingDirectory).then((_) {
            current.result = result;
            return;
          });
        });
      });
    });
  }

  ProjectTool getCleaner() {
    return new Cleaner();
  }

  ProjectTool getCompiler() {
    switch(_platform) {
      case 'linux':
        return new GnuCompiler();
      case 'macos':
        return new GnuCompiler();
      case 'windows':
        return new MsvcCompiler();
      default:
        _unsupportedPlatform();
        break;
    }
  }

  ProjectTool getLinker() {
    switch(_platform) {
      case 'linux':
        return new GnuLinker();
      case 'macos':
        return new GnuLinker();
      case 'windows':
        return new MsvcLinker();
      default:
        _unsupportedPlatform();
        break;
    }
  }

  Async<Project> loadProject(String filepath, [String format]) {
    return ProjectHelper.load(filepath, format);
  }

  Project loadProjectSync(String filepath, [String format]) {
    return ProjectHelper.loadSync(filepath, format);
  }

  bool isSupportedPlatform(String platform) {
    return ['linux', 'macos', 'windows'].any((elem) => elem == platform);
  }

  void _unsupportedPlatform() {
    throw('Unsupported target $_platform.');
  }
}
