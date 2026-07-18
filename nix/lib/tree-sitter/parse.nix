{
  lib,
  runCommand,
  tree-sitter,
}:
{
  configPath ? null,
  cst ? null,
  debug ? null,
  debugBuild ? null,
  debugGraph ? null,
  dot ? null,
  edits ? [ ],
  encoding ? null,
  env ? { },
  grammarPath ? null,
  jsonSummary ? null,
  langName ? null,
  libPath ? null,
  noRanges ? null,
  paths ? [ ],
  pathsFile ? null,
  quiet ? null,
  rebuild ? null,
  scope ? null,
  stat ? null,
  testNumber ? null,
  time ? null,
  timeout ? null,
  xml ? null,
}:
let
  boolFlag = name: val: lib.optionalString (val != null) "--${name}";
  valFlag = name: val: lib.optionalString (val != null) "--${name} ${lib.escapeShellArg "${val}"}";

  cstArg = boolFlag "cst" cst;
  debugArg =
    if debug == null then
      ""
    else if builtins.isString debug then
      "--debug ${lib.escapeShellArg debug}"
    else
      "--debug";
  debugBuildArg = boolFlag "debug-build" debugBuild;
  debugGraphArg = boolFlag "debug-graph" debugGraph;
  dotArg = boolFlag "dot" dot;
  jsonSummaryArg = boolFlag "json-summary" jsonSummary;
  noRangesArg = boolFlag "no-ranges" noRanges;
  quietArg = boolFlag "quiet" quiet;
  rebuildArg = boolFlag "rebuild" rebuild;
  statArg = boolFlag "stat" stat;
  timeArg = boolFlag "time" time;
  xmlArg = boolFlag "xml" xml;

  configPathArg = valFlag "config-path" configPath;
  encodingArg = valFlag "encoding" encoding;
  grammarPathArg = valFlag "grammar-path" grammarPath;
  langNameArg = valFlag "lang-name" langName;
  libPathArg = valFlag "lib-path" libPath;
  scopeArg = valFlag "scope" scope;
  testNumberArg = valFlag "test-number" testNumber;
  timeoutArg = valFlag "timeout" timeout;

  pathsFileArg = lib.optionalString (pathsFile != null) "--paths ${lib.escapeShellArg pathsFile}";
  editsArgs = lib.concatMapStringsSep " " (e: "--edits ${lib.escapeShellArg e}") edits;
in
runCommand "tree-sitter-parse" env ''
  runHook preRun

  # tree-sitter reads ~/.config/tree-sitter/config.json at startup
  export HOME="$(mktemp -d)"

  ${tree-sitter}/bin/tree-sitter parse \
    ${cstArg} \
    ${configPathArg} \
    ${debugArg} \
    ${debugBuildArg} \
    ${debugGraphArg} \
    ${dotArg} \
    ${editsArgs} \
    ${encodingArg} \
    ${grammarPathArg} \
    ${jsonSummaryArg} \
    ${langNameArg} \
    ${libPathArg} \
    ${noRangesArg} \
    ${pathsFileArg} \
    ${quietArg} \
    ${rebuildArg} \
    ${scopeArg} \
    ${statArg} \
    ${testNumberArg} \
    ${timeArg} \
    ${timeoutArg} \
    ${xmlArg} \
    ${lib.escapeShellArgs paths} \
    ${lib.optionalString (dot == null) "> $out"}

  # --dot writes log.html instead of stdout
  ${lib.optionalString (dot != null) "mv log.html $out"}

  runHook postRun
''
