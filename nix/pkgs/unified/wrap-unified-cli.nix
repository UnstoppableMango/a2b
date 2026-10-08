# Wraps a unified CLI so it always loads `plugins`, the way
# python3.withPackages does. Backs `remark-cli.withPlugins`.
{
  lib,
  makeWrapper,
  runCommand,
  unifiedRc,
}:
{
  cli,
  plugins ? [ ],
  settings ? { },
}:
let
  exe = cli.meta.mainProgram;

  rc = unifiedRc {
    name = "${cli.pname}-with-plugins";
    inherit plugins settings;
  };
in
runCommand "${cli.pname}-with-plugins-${cli.version}"
  {
    nativeBuildInputs = [ makeWrapper ];

    passthru = {
      inherit rc;
      unwrapped = cli;
    };

    meta = cli.meta // {
      mainProgram = exe;
    };
  }
  ''
    makeWrapper ${lib.getExe cli} "$out/bin/${exe}" --add-flags "--rc-path ${rc}"
  ''
