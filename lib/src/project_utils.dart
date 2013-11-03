part of ccompile.ccompile;

class ProjectHelper {
  static Project create(Map map) {
    var parser = new ProjectParser();
    var project = parser.parse(map);
    if(parser.hasErrors) {
      var nl = Platform.operatingSystem == 'windows' ? '\r\n' : '\n';
      var errors = parser.errors.join(nl);
      throw('During the parsing of the project there was an error(s):$nl$errors');
    }

    return project;
  }

  static Project load(String filepath, [String format]) {
    if(filepath == null || filepath.isEmpty) {
      throw new ArgumentError('filename: $filepath');
    }

    if(format != null && format != 'json' && format != 'yaml') {
      throw new ArgumentError('format: $format');
    }

    if(format == null) {
      var ext = pathos.extension(filepath);
      switch(ext.toLowerCase()) {
        case '.json':
          format = 'json';
          break;
        case '.yaml':
        case '.yml':
          format = 'yaml';
          break;
        default:
          throw('Unrecognized format of file "$filepath".');
      }
    }

    var text = FileUtils.readAsStringSync(filepath);

    var map;
    if(format == 'json') {
      map = JSON.parse(text);
    }

    if(format == 'yaml') {
      map = loadYaml(text);
    }

    if(map is! Map) {
      throw('Invalid project structure. Project must be a Map.');
    }

    return create(map);
  }
}
