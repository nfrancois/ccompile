library ccompile.bin.ccompile;

import 'dart:io';
import 'package:args/args.dart';
import 'package:ccompile/ccompile.dart';
import 'package:path/path.dart' as pathos;

void main(List<String> args) {
  Program.main(args.toList());
}

class Program {
  static void main(List<String> args) {
    var tool = new CcompileTool();
    var result = tool.run(args);
    exitCode = result;
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

  int run(List<String> args) {
    if(_parse(args)) {
      if(_prepare()) {
        return _build();
      }
    }

    return 1;
  }

  bool _parse(List<String> args) {
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

    if(args.length == 0) {
      _printUsage();
      return false;
    }

    projectArgument = args[0];
    args.removeRange(0, 1);
    var argResults;
    try {
      argResults = _parser.parse(args);
    } on FormatException catch (fe) {
      SystemUtils.writeString(fe.message, stderr);
      _printUsage();
      return false;
    } catch(e) {
      throw(e);
    }

    if(argResults.rest.length != 0) {
      SystemUtils.writeString('Illegal arguments:', stderr);
      argResults.rest.forEach((arg) => SystemUtils.writeString(arg, stderr));
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
      SystemUtils.writeString('Project file "$projectArgument" not found.', stderr);
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
      return 1;
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

  void _printUsage() {
    print('');
    print('Usage: ccompile.dart project [options]');
    print('Options:');
    print(_parser.getUsage());
  }
}
