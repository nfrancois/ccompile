library ccompile.bin.ccompile;

import 'dart:io';
import 'package:args/args.dart';
import 'package:ccompile/ccompile.dart';
import 'package:path/path.dart' as pathos;

void main(List<String> args) {
  Program.main(args);
}

class Program {
  static void main(List<String> args) {
    var tool = new CcompileTool();
    var result = tool.run();
    exit(result);
  }
}

class CcompileTool {
  bool clean = true;

  bool compile = true;

  bool link = true;

  String format;

  String projectArgument;

  String projectDirectory;

  String projectFileName;

  String projectFullPath;

  ArgParser _parser;

  int run() {
    if(_parse()) {
      if(_prepare()) {
        return _build();
      }
    }

    return -1;
  }

  bool _parse() {
    _parser = new ArgParser();
    _parser.addFlag('compile', abbr: 'c', defaultsTo: true,
      help: 'Compile project');
    _parser.addFlag('clean', abbr: 'n', defaultsTo: true, help: 'Clean project');
    _parser.addFlag('link', abbr: 'l', defaultsTo: true, help: 'Link project');
    _parser.addOption('format', abbr: 'f', allowed: ['json', 'yaml'],
      help: 'Project file format. Specify format other than project filename extension',
      allowedHelp: {
        'json': 'The project format is JSON',
        'yaml': 'The project format is YAML',
      });

    var options = new Options();
    if(options.arguments.length == 0) {
      _printUsage();
      return false;
    }

    var arguments = options.arguments;
    projectArgument = arguments[0];
    arguments.removeRange(0, 1);
    var argResults;
    try {
      argResults = _parser.parse(arguments);
    } on FormatException catch (fe) {
      stderr.writeln(fe.message);
      _printUsage();
      return false;
    } catch(e) {
      throw(e);
    }

    if(argResults.rest.length != 0) {
      stderr.writeln('Illegal arguments:');
      argResults.rest.forEach((arg) => stderr.writeln(arg));
      _printUsage();
      return false;
    }

    clean = argResults['clean'];
    compile = argResults['compile'];
    link = argResults['link'];
    format = argResults['format'];
    return true;
  }

  bool _prepare() {
    projectDirectory = _getDirectoryPath(projectArgument);
    if(projectDirectory == null) {
      stderr.writeln('Project file "$projectArgument" not found.');
      return false;
    }


    projectFileName = pathos.basename(projectArgument);
    projectFullPath = pathos.join(projectDirectory, projectFileName);
    return true;
  }

  int _build() {
    var builder = new ProjectBuilder();
    var project = builder.loadProject(projectFullPath, format);
    var result = builder.customBuild(project, projectDirectory, compile, link, clean);
    if(result.exitCode != 0) {
      stdout.writeln(result.stdout);
      stderr.writeln(result.stderr);
      return -1;
    } else {
      return 0;
    }
  }

  String _getDirectoryPath(String filename) {
    var path = filename;
    if(!pathos.isAbsolute(path)) {
      var curDirPath = Directory.current.path;
      pathos.join(curDirPath, path);
      filename = path;
    }

    var file = new File(filename);
    if(!file.existsSync()) {
      return  null;
    }

    return file.parent.path;
  }

  String _printUsage() {
    stdout.writeln('');
    stdout.writeln('Usage: ccompile.dart project [options]');
    stdout.writeln('Options:');
    stdout.writeln(_parser.getUsage());
  }
}
