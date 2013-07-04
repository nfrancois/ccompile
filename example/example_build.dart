library example_build;

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:async/async.dart';
import 'package:ccompile/ccompile.dart';

void main() {
  new Async(() {
    var projectPath = Utils.toAbsolutePath('../example/sample_extension.yaml');
    Utils.buildProject(projectPath, {
      'start': 'Building project "$projectPath"',
      'success': 'Building complete successfully',
      'error': 'Building complete with some errors'})
    .then((result) {
      exit(result);
    });
  });
}

class Utils {
  static Async<int> buildProject(projectPath, Map messages) {
    return new Async<int>(() {
      Async<int> current = Async.current;
      var workingDirectory = new Path(projectPath).directoryPath.toNativePath();
      var message = messages['start'];
      if(!message.isEmpty) {
        Utils.writeString(message, stdout);
      }

      var builder = new ProjectBuilder();
      builder.loadProject(projectPath)
      .then((project) {
        builder.buildAndClean(project, workingDirectory)
        .then((result) {
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
    });
  }

  static String toAbsolutePath(String path) {
    return new Path(Utils.getRootScriptDirectory()).join
        (new Path(path)).toNativePath();
  }

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
