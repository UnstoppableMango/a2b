# `likec4 gen <format>` into the directory $out. Diagram formats (mermaid, dot,
# d2, plantuml) write one file per view. Formats that emit a single module write
# it as $out/<outfile>, since likec4 picks the module type from its extension.
{
  lib,
  likec4,
  runCommand,
}:
{
  env ? { },
  flags ? [ ],
  format,
  name,
  outfile ? null,
  src,
}:
let
  defaultOutfiles = {
    react = "likec4-views.jsx";
    webcomponent = "likec4-views.js";
    wc = "likec4-views.js";
    webcomp = "likec4-views.js";
    model = "likec4-model.ts";
    ts = "likec4-model.ts";
  };

  file = if outfile != null then outfile else defaultOutfiles.${format} or null;
  output = if file != null then "$out/${lib.escapeShellArg file}" else "$out";
in
runCommand name env ''
  runHook preBuild

  export HOME="$(mktemp -d)"
  mkdir -p $out
  ${likec4}/bin/likec4 gen ${lib.escapeShellArg format} \
    --output ${output} \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg "${src}"}

  runHook postBuild
''
