{
  lib,
  runCommand,
  tree-sitter,
}:
{
  capturesPath ? null,
  check ? null,
  configPath ? null,
  cssClasses ? null,
  env ? { },
  grammarPath ? null,
  html ? null,
  paths ? [ ],
  pathsFile ? null,
  queryPaths ? [ ],
  quiet ? null,
  rebuild ? null,
  scope ? null,
  testNumber ? null,
  time ? null,
}:
let
  boolFlag = name: val: lib.optionalString (val != null) "--${name}";
  valFlag =
    name: val: lib.optionalString (val != null) "--${name} ${lib.escapeShellArg (toString val)}";

  htmlArg = boolFlag "html" html;
  cssClassesArg = boolFlag "css-classes" cssClasses;
  checkArg = boolFlag "check" check;
  quietArg = boolFlag "quiet" quiet;
  rebuildArg = boolFlag "rebuild" rebuild;
  timeArg = boolFlag "time" time;

  capturesPathArg = valFlag "captures-path" capturesPath;
  configPathArg = valFlag "config-path" configPath;
  grammarPathArg = valFlag "grammar-path" grammarPath;
  scopeArg = valFlag "scope" scope;
  testNumberArg = valFlag "test-number" testNumber;

  pathsFileArg = lib.optionalString (pathsFile != null) "--paths ${lib.escapeShellArg pathsFile}";
  queryPathsArgs = lib.concatMapStringsSep " " (
    p: "--query-paths ${lib.escapeShellArg p}"
  ) queryPaths;
in
runCommand "tree-sitter-highlight" env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  ${tree-sitter}/bin/tree-sitter highlight \
    ${htmlArg} \
    ${cssClassesArg} \
    ${checkArg} \
    ${capturesPathArg} \
    ${queryPathsArgs} \
    ${scopeArg} \
    ${timeArg} \
    ${quietArg} \
    ${pathsFileArg} \
    ${grammarPathArg} \
    ${configPathArg} \
    ${testNumberArg} \
    ${rebuildArg} \
    ${lib.escapeShellArgs paths} \
    > $out

  runHook postRun
''
