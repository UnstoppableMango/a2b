# Turns a plugin, as builders take it, into the entry an rc or an options file
# names: a derivation becomes its entry file, `passthru.unifiedPlugin`, which
# every plugin in unmango/pkgs' unifiedPackages sets. ESM refuses directory
# imports, so the file has to be named.
#
#   remark-gfm  [ remark-toc { heading = "Contents"; } ]  "/abs/plugin.js"
{ lib }:
let
  entry =
    plugin:
    if lib.isDerivation plugin then
      plugin.unifiedPlugin
        or (throw "${plugin.name} has no passthru.unifiedPlugin; pass the path of its entry file instead")
    # Interpolated, so a local file is copied to the store and reaches the
    # sandbox; toString would leave it outside.
    else if lib.isPath plugin then
      "${plugin}"
    else
      toString plugin;
in
plugin: if lib.isList plugin then [ (entry (lib.head plugin)) ] ++ lib.tail plugin else entry plugin
