{
  lib,
  runCommand,
  tree-sitter,
}:
{
  abiVersion ? null,
  build ? null,
  debugBuild ? null,
  disableOptimizations ? null,
  env ? { },
  grammarPath ? null,
  jsRuntime ? null,
  jsonSummary ? null,
  libdir ? null,
  log ? null,
  noParser ? null,
  reportStatesForRule ? null,
}:
let
  boolFlag = name: val: lib.optionalString (val != null) "--${name}";
  valFlag = name: val: lib.optionalString (val != null) "--${name} ${lib.escapeShellArg "${val}"}";

  logArg = boolFlag "log" log;
  buildArg = boolFlag "build" build;
  debugBuildArg = boolFlag "debug-build" debugBuild;
  noParserArg = boolFlag "no-parser" noParser;
  jsonSummaryArg = boolFlag "json-summary" jsonSummary;
  disableOptimizationsArg = boolFlag "disable-optimizations" disableOptimizations;

  abiVersionArg = valFlag "abi" abiVersion;
  libdirArg = valFlag "libdir" libdir;
  reportStatesForRuleArg = valFlag "report-states-for-rule" reportStatesForRule;
  jsRuntimeArg = valFlag "js-runtime" jsRuntime;

  grammarPathArg = lib.optionalString (grammarPath != null) (lib.escapeShellArg grammarPath);
in
runCommand "tree-sitter-generate" env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  ${tree-sitter}/bin/tree-sitter generate \
    ${logArg} \
    ${abiVersionArg} \
    ${noParserArg} \
    ${buildArg} \
    ${debugBuildArg} \
    ${libdirArg} \
    --output $out \
    ${reportStatesForRuleArg} \
    ${jsonSummaryArg} \
    ${jsRuntimeArg} \
    ${disableOptimizationsArg} \
    ${grammarPathArg}

  runHook postRun
''
