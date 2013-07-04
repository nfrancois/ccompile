part of ccompile;

class MsvcUtils {
  static Async<String> getEnvironmentScript(int bits) {
    return new Async<String>(() {
      Async<String> current = Async.current;
      if(bits == null || (bits != 32 && bits != 64)) {
        throw new ArgumentError('bits: $bits');
      }

      var key = r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio';
      WindowsRegistry.queryAllKeys(key)
      .then((reg) {
        if(reg == null) {
          return null;
        }

        var regVC7 = reg[r'SxS\VC7'];
        if(regVC7 == null) {
          return null;
        }

        var versions = [];
        for(var version in reg.keys.keys) {
          if(regVC7.values.containsKey(version)) {
            versions.add(regVC7.values[version].value);
          }
        }

        if(versions.length == 0) {
          return null;
        }

        var scriptName = '';
        switch(bits) {
          case 32:
            scriptName = 'vcvars32.bat';
            break;
          case 64:
            scriptName = 'vcvarsx86_amd64.bat';
            break;
        }

        if(scriptName.isEmpty) {
          return null;
        }

        var fullScriptPath = '';
        for(var i = versions.length; i > 0; i--) {
          var vc7Path = versions[i - 1];
          var file = new File('${vc7Path}bin\\$scriptName');

          if(file.existsSync()) {
            fullScriptPath = file.fullPathSync();
            break;
          }
        }

        if(fullScriptPath.isEmpty) {
          return null;
        }

        current.result = fullScriptPath;
      });
    });
  }

  static Async<Map<String, String>> getEnvironment(int bits) {
    return new Async<Map<String, String>>(() {
      Async<Map<String, String>> current  = Async.current;
      if(bits == null || (bits != 32 && bits != 64)) {
        throw new ArgumentError('bits: $bits');
      }

      getEnvironmentScript(bits)
      .then((script) {
        if(script == null) {
          return null;
        }

        var executable = '"$script" && set';
        var process = Process.run(executable, []);
        new Async.fromFuture(process)
        .then((ProcessResult result) {
          if(result != null && result.exitCode == 0) {
            var env = new Map<String, String>();
            var exp = new RegExp(r'(^\S+)=(.*)$', multiLine: true);
            var matches = exp.allMatches(result.stdout);
            for(var match in matches) {
              env[match.group(1)] = match.group(2);
            }

            current.result = env;
          }
        });
      });
    });
  }
}
