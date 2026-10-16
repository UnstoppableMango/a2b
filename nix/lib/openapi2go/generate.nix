# `openapi2go <spec>` into the directory $out, as one Go file. openapi2go's own
# `--output` always names the file petstore.go, so stdout is captured instead.
# The package clause comes from the spec's `info.title` when that is a valid Go
# package name; `packageName` only applies otherwise.
{
  cli,
  lib,
  openapi2go,
  runCommand,
}:
{
  config ? null,
  env ? { },
  flags ? [ ],
  name,
  outfile ? "openapi2go.zz_generated.go",
  packageName ? null,
  src,
}:
runCommand name env ''
  runHook preBuild

  mkdir -p $out
  ${openapi2go}/bin/openapi2go ${lib.escapeShellArg "${src}"} \
    ${cli.optionalArg "config" config} \
    ${cli.optionalArg "package-name" packageName} \
    ${lib.escapeShellArgs flags} \
    > $out/${lib.escapeShellArg outfile}

  runHook postBuild
''
