# Writes a unified-engine rc file whose plugins are absolute store paths, so
# nothing is resolved by package name.
#
#   plugins = [ remark-gfm [ remark-toc { heading = "Contents"; } ] "/abs/plugin.js" ];
#
# A derivation resolves to its entry file, `passthru.unifiedPlugin`, which
# every plugin in unmango/pkgs' unifiedPackages sets. ESM refuses directory
# imports, so the file has to be named.
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
      plugin.unifiedPlugin
        or (throw "${plugin.name} has no passthru.unifiedPlugin; pass the path of its entry file instead")
    else
      toString plugin;

  toRc =
    plugin:
    if lib.isList plugin then [ (entry (lib.head plugin)) ] ++ lib.tail plugin else entry plugin;
in
(formats.json { }).generate "${name}-rc.json" (
  { plugins = map toRc plugins; } // lib.optionalAttrs (settings != { }) { inherit settings; }
)
