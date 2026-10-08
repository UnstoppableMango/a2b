# Writes a unified-engine rc file whose plugins are absolute store paths, so
# nothing is resolved by package name.
#
#   plugins = [ remark-gfm [ remark-toc { heading = "Contents"; } ] "/abs/plugin.js" ];
#
# A derivation resolves to its package's entry file: `passthru.unifiedEntry`
# when set, else index.js, which every unified plugin uses. ESM refuses
# directory imports, so the file has to be named.
{ lib, formats }:
{
  name ? "unified",
  plugins ? [ ],
  settings ? { },
}:
let
  entry =
    plugin:
    if lib.isDerivation plugin then
      "${plugin}/lib/node_modules/${plugin.pname}/${plugin.unifiedEntry or "index.js"}"
    else
      toString plugin;

  toRc =
    plugin:
    if lib.isList plugin then [ (entry (lib.head plugin)) ] ++ lib.tail plugin else entry plugin;
in
(formats.json { }).generate "${name}-rc.json" (
  { plugins = map toRc plugins; } // lib.optionalAttrs (settings != { }) { inherit settings; }
)
