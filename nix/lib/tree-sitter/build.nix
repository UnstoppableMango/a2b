{
  lib,
  runCommand,
  tree-sitter,
}:
{
  debug ? null,
  env ? { },
  grammarPath ? null,
  reuseAllocator ? null,
  wasm ? null,
}:
let
  boolFlag = name: val: lib.optionalString (val != null) "--${name}";

  debugArg = boolFlag "debug" debug;
  reuseAllocatorArg = boolFlag "reuse-allocator" reuseAllocator;
  wasmArg = boolFlag "wasm" wasm;

  grammarPathArg = lib.optionalString (grammarPath != null) (lib.escapeShellArg grammarPath);
in
runCommand "tree-sitter-build" env ''
  runHook preRun

  export HOME="$(mktemp -d)"

  ${tree-sitter}/bin/tree-sitter build \
    ${wasmArg} \
    --output $out \
    ${reuseAllocatorArg} \
    ${debugArg} \
    ${grammarPathArg}

  runHook postRun
''
