library ccompile.example.example_build_from_cmdline;

import 'dart:io';
import 'package:path/path.dart' as pathos;

void main(List<String> args) {
  Program.main(args);
}

class Program {
  static void main(List<String> args) {
    var projectPath = toAbsolutePath('../example/sample_extension.yaml');
    var env = 'CCOMPILE';
    var ccompile = 'ccompile.dart';
    var script = findFile(env, ccompile);
    if(script.isEmpty) {
      errorFileNotFound(env, ccompile);
    }

    var result = runDartScript([script, projectPath], {
      'start': 'Building project "$projectPath"',
      'success': 'Building complete successfully',
      'error': 'Building complete with some errors'});

    exit(result);
  }

  static int runDartScript(List arguments, Map messages) {
    var dart = findDartVM();
    var message = messages['start'];
    if(!message.isEmpty) {
      stdout.writeln(message);
    }

    var result = Process.runSync(dart, arguments);
    if(result.exitCode == 0) {
      var message = messages['success'];
      if(!message.isEmpty) {
        stdout.writeln(message);
      }
    } else {
      var message = messages['error'];
      if(!message.isEmpty) {
        stdout.writeln(message);
      }

      stdout.writeln(result.stdout);
      stderr.writeln(result.stderr);
    }

    return result.exitCode == 0 ? 0 : -1;
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
    stderr.writeln('Error: Cannot find "$filename" either in env["PATH"] nor in env["${env}"]');
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
      var path = pathos.join(item, filename);
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

    if(subdir != null) {
      path = pathos.join(path, subdir);
    }

    path = pathos.join(path, filename);
    if(new File(path).existsSync()) {
      return path;
    }

    return '';
  }

  static String toAbsolutePath(String path) {
    return pathos.join(getRootScriptDirectory(), path);
  }

  static String getRootScriptDirectory() {
    return pathos.dirname(Platform.script);
  }
}

