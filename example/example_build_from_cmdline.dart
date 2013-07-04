import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:mirrors';

import 'package:async/async.dart';

main() {
  var projectPath = Utils.toAbsolutePath('../example/sample_extension.yaml');
  var env = 'CCOMPILE';
  var ccompile = 'ccompile.dart';
  var script = Utils.findFile(env, ccompile);
  if(script.isEmpty) {
    Utils.errorFileNotFound(env, ccompile);
  }

  Utils.runDartScript([script, projectPath], {
    'start': 'Building project "$projectPath"',
    'success': 'Building complete successfully',
    'error': 'Building complete with some errors'})
    .then((exitCode) {});
}

class Utils {
  static Async<int> runDartScript(List arguments, Map messages) {
    return new Async(() {
      var current = Async.current;
      var dart = findDartVM();
      var message = messages['start'];
      if(!message.isEmpty) {
        Utils.writeString(message, stdout);
      }

      new Async.fromFuture(Process.run(dart, arguments))
        .then((ProcessResult result) {
        if(result.exitCode == 0) {
          var message = messages['success'];
          if(!message.isEmpty) {
            Utils.writeString(message, stdout);
          }
        } else {
          var message = messages['error'];
          if(!message.isEmpty) {
            Utils.writeString(message, stdout);
          }

          Utils.writeString(result.stdout, stdout);
          Utils.writeString(result.stderr, stderr);
        }

        current.result = result.exitCode == 0 ? 0 : -1;
      });
    });
  }

  static String findDartVM() {
    var filename;
    if(Platform.operatingSystem == 'windows') {
      filename = 'dart.exe';
    } else {
      filename = 'dart';
    }

    var env = 'DART_SDK';
    var dart = findFile(env, filename, 'bin');
    if(!dart.isEmpty) {
      return dart;
    }

    errorFileNotFound(env, filename);
  }

  static void errorFileNotFound(String env, String filename) {
    writeString('Error: Cannot find "$filename" either in env["PATH"] nor in env["${env}"]', stderr);
    exit(-1);
  }

  static String findFile(String env, String filename, [String subdir]) {
    var path = findFileInPathEnv(filename);
    if(!path.isEmpty) {
      return path;
    }

    return findFileInEnv(env, filename, subdir);
  }

  static String findFileInPathEnv(String filename) {
    var separator = Platform.operatingSystem == 'windows' ? ';' : ':';
    var envPath = Platform.environment['PATH'];
    if(envPath == null) {
      return '';
    }

    for(var item in envPath.split(separator)) {
      var path = new Path('$item').append(filename).toNativePath();
      if(new File(path).existsSync()) {
        return path;
      }
    }

    return '';
  }

  static String findFileInEnv(String env, String filename, [String subdir]) {
    if(env == null || env.isEmpty) {
      return '';
    }

    var path = Platform.environment[env];
    if(path == null) {
      return '';
    }

    path = new Path('$path');
    if(subdir != null) {
      path = path.append(subdir);
    }

    path = path.append(filename).toNativePath();
    if(new File(path).existsSync()) {
      return path;
    }

    return '';
  }

  static String toAbsolutePath(String path) {
    return new Path(Utils.getRootScriptDirectory()).join
        (new Path(path)).toNativePath();
  }

  static String newline = Platform.operatingSystem == 'windows' ? '\r\n' : '\n';

  static void writeString(String string, IOSink stream) {
    stream.writeln('$string');
  }

  static String getRootScriptDirectory() {
    var reflection = currentMirrorSystem();
    var file = '${reflection.isolate.rootLibrary.uri}';
    if(Platform.operatingSystem == 'windows') {
      file = file.replaceAll('file:///', '');
    } else {
      file = file.replaceAll('file://', '');
    }

    return new Path(file).directoryPath.toNativePath();
  }
}
