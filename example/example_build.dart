library ccompile.example.example_build;

import 'dart:io';
import 'package:ccompile/ccompile.dart';
import 'package:path/path.dart' as pathos;

void main(List<String> args) {
  Program.main(args);
}

class Program {
  static void main(List<String> args) {
    var projectPath = toAbsolutePath('../example/sample_extension.yaml');
    var result = Program.buildProject(projectPath, {
      'start': 'Building project "$projectPath"',
      'success': 'Building complete successfully',
      'error': 'Building complete with some errors'});

    exit(result);
  }

  static int buildProject(projectPath, Map messages) {
    var workingDirectory = pathos.dirname(projectPath);
    var message = messages['start'];
    if(!message.isEmpty) {
      stdout.writeln(message);
    }

    var builder = new ProjectBuilder();
    var project = builder.loadProject(projectPath);
    var result = builder.buildAndClean(project, workingDirectory);
    if(result.exitCode == 0) {
      var message = messages['success'];
      if(!message.isEmpty) {
        stdout.writeln(message);
      }
    } else {
      var message = messages['error'];
      if(!message.isEmpty) {
        stderr.writeln(message);
      }

      stdout.writeln(result.stdout);
      stderr.writeln(result.stderr);
    }

    return result.exitCode == 0 ? 0 : -1;
  }

  static String toAbsolutePath(String path) {
    return pathos.join(getRootScriptDirectory(), path);
  }

  static String getRootScriptDirectory() {
    return pathos.dirname(Platform.script);
  }
}
