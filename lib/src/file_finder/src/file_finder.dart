part of file_finder;

class FileFinder {
  static List<String> find(String path, List<String> filemasks, {bool searchForFiles: true,
    bool searchForDirs: false, bool recursive: false , bool ignoreCase}) {
    var dirs = {};
    var basePath = path;
    filemasks.forEach((filemask) {
      var filePath = filemask;
      // Skip filemask with absoulute path.
      if(pathos.isAbsolute(filePath)) {
        return;
      }

      var mask = pathos.basename(filePath);
      if(mask.trim().isEmpty) {
        return;
      }

      var dirPath = pathos.dirname(pathos.join(basePath, filemask));
      var dirName = dirPath;
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
      var lister = new FilteredDirectoryLister(dir, dirs[dirName], recursive, ignoreCase);
      if(searchForFiles) {
        lister.onFile = (file) => results.add(file);
      }

      if(searchForDirs) {
        lister.onDir = (dir) => results.add(dir);
      }

      lister.list();
    });

    return results;
  }
}
