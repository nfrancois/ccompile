part of file_finder;

class FileFinder {
  static Future<List<String>> find(String path, List<String> filemasks,
      {bool searchForFiles: true, bool searchForDirs: false,
      bool recursive: false, bool ignoreCase}) {
    var dirs = {};
    var basePath = new Path(path);
    filemasks.forEach((filemask) {
      var filePath = new Path(filemask);
      // Skip filemask with absoulute path.
      if(filePath.isAbsolute) {
        return;
      }

      var mask = filePath.filename;
      if(mask.trim().isEmpty) {
        return;
      }

      var dirPath = basePath.append(filemask).directoryPath;
      var dirName = dirPath.toNativePath();
      var dirMasks;
      if(dirs.containsKey(dirName)) {
        dirMasks = dirs[dirName];
      } else {
        dirs[dirName] = dirMasks = [];
      }

      dirMasks.add(mask);
    });

    var results = [];
    var futures = [];
    dirs.keys.forEach((dirName) {
      var dir = new Directory(dirName);
      var lister = new FilteredDirectoryLister(dir, dirs[dirName],
          recursive, ignoreCase);
      if(searchForFiles) {
        lister.onFile = (file) => results.add(file);
      }

      if(searchForDirs) {
        lister.onDir = (dir) => results.add(dir);
      }

      var completer = new Completer<List<String>>();
      lister.onDone = () => completer.complete(results);

      futures.add(completer.future);
    });

    return Future.wait(futures).then((_) {
      return new Future.sync(() => results);
    });
  }
}
