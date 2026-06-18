{
  byteRange ? null,
  captures ? null,
  configPath ? null,
  containingByteRange ? null,
  containingRowRange ? null,
  env ? { },
  grammarPath ? null,
  langName ? null,
  lib,
  libPath ? null,
  paths ? [ ],
  pathsFile ? null,
  queryPath,
  quiet ? null,
  rebuild ? null,
  rowRange ? null,
  runCommand,
  scope ? null,
  test ? null,
  testNumber ? null,
  time ? null,
  tree-sitter,
}:
let
  boolFlag = name: val: lib.optionalString (val != null) "--${name}";
  valFlag =
    name: val: lib.optionalString (val != null) "--${name} ${lib.escapeShellArg (toString val)}";

  capturesArg = boolFlag "captures" captures;
  quietArg = boolFlag "quiet" quiet;
  rebuildArg = boolFlag "rebuild" rebuild;
  testArg = boolFlag "test" test;
  timeArg = boolFlag "time" time;

  byteRangeArg = valFlag "byte-range" byteRange;
  configPathArg = valFlag "config-path" configPath;
  containingByteRangeArg = valFlag "containing-byte-range" containingByteRange;
  containingRowRangeArg = valFlag "containing-row-range" containingRowRange;
  grammarPathArg = valFlag "grammar-path" grammarPath;
  langNameArg = valFlag "lang-name" langName;
  libPathArg = valFlag "lib-path" libPath;
  rowRangeArg = valFlag "row-range" rowRange;
  scopeArg = valFlag "scope" scope;
  testNumberArg = valFlag "test-number" testNumber;

  pathsFileArg = lib.optionalString (pathsFile != null) "--paths ${lib.escapeShellArg pathsFile}";
in
runCommand "tree-sitter-query" env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  ${tree-sitter}/bin/tree-sitter query \
    ${capturesArg} \
    ${byteRangeArg} \
    ${containingByteRangeArg} \
    ${rowRangeArg} \
    ${containingRowRangeArg} \
    ${scopeArg} \
    ${grammarPathArg} \
    ${libPathArg} \
    ${langNameArg} \
    ${pathsFileArg} \
    ${configPathArg} \
    ${testNumberArg} \
    ${testArg} \
    ${timeArg} \
    ${quietArg} \
    ${rebuildArg} \
    ${lib.escapeShellArg queryPath} \
    ${lib.escapeShellArgs paths} \
    > $out

  runHook postRun
''
