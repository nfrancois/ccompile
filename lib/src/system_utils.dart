part of ccompile.ccompile;

class SystemUtils {
  static List<String> expandEnvironmentVars(List<String> strings) {
    var list = [];
    var len = strings.length;
    for (var string in strings) {
      list.add(_expandMacro(string, (s) {
        var result = Platform.environment[s];
        if (result == null && s == "DART_SDK") {
          result = DART_SDK;
        }

        return result == null ? '' : result;
      }));
    }

    return list;
  }

  static String _expandMacro(String string, String callback(String)) {
    RegExp exp = new RegExp(r'({\S+?})');
    var matches = exp.allMatches(string);
    for (var match in matches) {
      var seq = match.group(0);
      var key = seq.substring(1, seq.length - 1);
      string = string.replaceAll(seq, callback(key));
    }

    return string;
  }

  static final String newline = Platform.operatingSystem == 'windows' ? '\r\n' : '\n';

  static void writeString(String text, IOSink sink) {
    sink.write('$text$newline');
  }
}
