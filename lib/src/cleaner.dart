part of ccompile.ccompile;

class Cleaner implements ProjectTool {
  ProcessResult run(Project project, [String workingDirectory]) {
    return _clean(project, workingDirectory);
  }

  ProcessResult _clean(Project project, String workingDirectory) {
    if(workingDirectory == null) {
      workingDirectory = Directory.current.path;
    }

    var files = FileFinder.find(workingDirectory, project.clean);
    files.forEach((file) {
      var fp = new File(file);
      if(fp.existsSync()) {
        fp.deleteSync();
      }
    });

    return new ProjectToolResult();
  }
}
