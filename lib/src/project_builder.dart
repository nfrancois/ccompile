part of ccompile.ccompile;

class ProjectBuilder {
  String _platform;

  ProjectBuilder() {
    _platform = Platform.operatingSystem;
  }

  ProcessResult build(Project project, [String workingDirectory]) {
    var result = compile(project, workingDirectory);
    if(result.exitCode != 0) {
      return result;
    }

    return link(project, workingDirectory);
  }

  ProcessResult compile(Project project, [String workingDirectory]) {
    return getCompiler().run(project, workingDirectory);
  }

  ProcessResult link(Project project, [String workingDirectory]) {
    return getLinker().run(project, workingDirectory);
  }

  ProcessResult clean(Project project, [String workingDirectory]) {
    return getCleaner().run(project, workingDirectory);
  }

  ProcessResult buildAndClean(Project project, [String workingDirectory]) {
    var result = build(project, workingDirectory);
    clean(project, workingDirectory);
    return result;
  }

  ProcessResult customBuild(Project project, [String workingDirectory, bool compile = true, bool link = true, bool clean = true]) {
    if(!compile) {
      return new ProjectToolResult();
    }

    var result = this.compile(project, workingDirectory);
    if(result.exitCode != 0 || !link) {
      return result;
    }

    result = this.link(project, workingDirectory);
    if(!clean) {
      return result;
    }

    this.clean(project, workingDirectory);
    return result;
  }

  ProjectTool getCleaner() {
    return new Cleaner();
  }

  ProjectTool getCompiler() {
    switch(_platform) {
      case 'android':
        return new GnuCompiler();
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
      case 'android':
        return new GnuLinker();
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

  Project loadProject(String filepath, [String format]) {
    return ProjectHelper.load(filepath, format);
  }

  bool isSupportedPlatform(String platform) {
    return ['android', 'linux', 'macos', 'windows'].any((elem) => elem == platform);
  }

  void _unsupportedPlatform() {
    throw('Unsupported target $_platform.');
  }
}
