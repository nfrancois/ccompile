part of file_finder;

class FilteredDirectoryLister {
  static List _metachars =
      const ['[', ']', '\\', '^', r'$', '|', '+', '(', ')'];

  //DirectoryLister _lister;

  Stream<FileSystemEntity> _lister;

  Function _onData;
  Function _onDone;
  Function _onError;
  Function _onDir;
  Function _onFile;

  List<List<Map>> _variants = [];

  FilteredDirectoryLister(Directory dir, List<String> filemasks,
      [bool recursive = false, bool ignoreCase]) {
    _lister = dir.list(recursive: recursive);

    void onData(entry) {
      var path = entry.path;
      if(FileSystemEntity.isDirectorySync(path)) {
        _filterDir(entry.path);
      } else if(FileSystemEntity.isFileSync(path)) {
        _filterFile(entry.path);
      }
    }

    void onDone() {
      if(_onDone != null) {
        _onDone();
      }
    }

    void onError(error) {
      if(_onError != null) {
        _onError(error);
      }
    }

    _lister.listen(onData, onError: onError, onDone: onDone);

    if(ignoreCase == null && Platform.operatingSystem == 'windows') {
      ignoreCase = true;
    } else {
      ignoreCase = false;
    }

    for(var filemask in filemasks) {
      _variants.add(_filemaskToRegExp(filemask, ignoreCase: ignoreCase));
    }
  }

  void set onDir(void onDir(String dir)) {
    _onDir = onDir;
  }

  void set onFile(void onFile(String file)) {
    _onFile = onFile;
  }

  void set onDone(void onDone()) {
    _onDone = onDone;
  }

  void set onError(void onError(e)) {
    _onError = onError;
  }

  void _filterDir(String dir) {
    _filter(dir, _onDir);
  }

  void _filterFile(String file) {
    _filter(file, _onFile);
  }

  void _filter(String filename, Function cb) {
    if(cb == null) {
      return;
    }

    var name = _getFilename(filename);
    if(_match(name, _variants)) {
      cb(filename);
    }
  }

  List<Map> _filemaskToRegExp(String filemask, {ignoreCase: false}) {
    var exprs = [];
    if(filemask == null) {
      return exprs;
    }

    for(var pattern in filemask.split('.')) {
      var map = {};
      map['mask'] = pattern;
      map['length'] = pattern.contains('*') ? -1 : pattern.length;

      pattern = pattern.replaceAll('*', '.*');
      pattern = pattern.replaceAll('?', '.');

      for(var metachar in _metachars) {
        pattern = pattern.replaceAll('$metachar', '\\$metachar');
      }

      map['reg_exp'] = new RegExp('^$pattern', multiLine: false, caseSensitive: !ignoreCase);
      exprs.add(map);
    }

    return exprs;
  }

  bool _match(String filename, List<List<Map>> variants) {
    var found = false;
    var parts = filename.split('.');
    var len = parts.length;
    for(var exprs in variants) {
      if(len != exprs.length) {
        continue;
      }

      found = true;
      for(var i = 0; i < len; i++) {
        var part = parts[i];
        var expr = exprs[i]['reg_exp'];
        var matches = expr.allMatches(part);
        var iterator = new HasNextIterator(matches.iterator);
        if(!iterator.hasNext) {
          found = false;
          break;
        } else {
          var lenSpec = exprs[i]['length'];
          if(lenSpec >= 0 && part.length != lenSpec) {
            found = false;
            break;
          }
        }
      }

      if(found) {
        break;
      }
    }

    return found;
  }

  String _getFilename(String path) {
    int unix = path.lastIndexOf('/');
    int windows = path.lastIndexOf('\\');
    if(unix == -1 && windows == -1) {
      return '';
    }

    var index = max(unix, windows);
    return path.substring(index + 1);
  }
}
