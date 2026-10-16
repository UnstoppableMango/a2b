# Writes a unified-engine rc file whose plugins are absolute store paths, so
# nothing is resolved by package name.
#
#   plugins = [ remark-gfm [ remark-toc { heading = "Contents"; } ] "/abs/plugin.js" ];
{
  lib,
  formats,
  toPlugin,
}:
{
  name ? "unified",
  plugins ? [ ],
  settings ? { },
}:
(formats.json { }).generate "${name}-rc.json" (
  { plugins = map toPlugin plugins; } // lib.optionalAttrs (settings != { }) { inherit settings; }
)
