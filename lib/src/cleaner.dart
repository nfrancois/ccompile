part of ccompile;

class Cleaner implements ProjectTool {
  Async<ProcessResult> run(Project project, [String workingDirectory]) {
    return _clean(project, workingDirectory);
  }

  Async<ProcessResult> _clean(Project project, String workingDirectory) {
    return new Async<ProcessResult>(() {
      if(workingDirectory == null) {
        workingDirectory = Directory.current.path;
      }

      var finder = FileFinder.find(workingDirectory, project.clean);
      new Async.fromFuture(finder).then((files) {
        files.forEach((file) {
          var fp = new File(file);
          if(fp.existsSync()) {
            fp.deleteSync();
          }
        });
      });

      return new ProjectToolResult();
    });
  }
}
