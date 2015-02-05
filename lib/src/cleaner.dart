part of ccompile.ccompile;

class Cleaner implements ProjectTool {
  ProcessResult run(Project project, [String workingDirectory]) {
    return _clean(project, workingDirectory);
  }

  ProcessResult _clean(Project project, String workingDirectory) {
    if (workingDirectory == null) {
      workingDirectory = Directory.current.path;
    }

    var files = <String>[];
    if (project.clean != null) {
      for (var file in project.clean) {
        if (workingDirectory != null) {
          file = lib_path.join(workingDirectory, file);
        }

        file = file.replaceAll("\\", "/");
        lib_file_utils.FileUtils.rm([file], force: true);
      }
    }

    return new ProjectToolResult();
  }
}
