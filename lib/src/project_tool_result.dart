part of ccompile.ccompile;

class ProjectToolResult implements ProcessResult {
  int _exitCode = 0;

  String _stdout = '';

  String _stderr = '';

  int get exitCode => _exitCode;

  int get pid => 0;

  String get stdout => _stdout;

  String get stderr => _stderr;

  ProjectToolResult();

  ProjectToolResult.error(this._exitCode, this._stdout, this._stderr);
}
