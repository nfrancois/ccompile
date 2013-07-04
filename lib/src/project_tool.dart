part of ccompile;

abstract class ProjectTool {
  Async<ProcessResult> run(Project project, [String workingDirectory]);
}
