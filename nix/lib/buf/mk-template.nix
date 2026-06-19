{
  formats,
  lib,
  name ? "buf.gen.yaml",
  plugins ? [ ],
  inputs ? [ ],
  ...
}@attrs:
let
  fmt = formats.yaml { };

  resolvePlugin =
    plugin:
    if plugin ? package then
      let
        pkg = plugin.package;
        binName = plugin.bin or (lib.getName pkg);
        rest = removeAttrs plugin [
          "package"
          "bin"
        ];
      in
      rest // { local = "${pkg}/bin/${binName}"; }
    else
      plugin;

  resolvedPlugins = map resolvePlugin plugins;

  yamlValue =
    removeAttrs attrs [
      "formats"
      "lib"
      "name"
      "plugins"
    ]
    // {
      version = attrs.version or "v2";
      inherit inputs;
      plugins = resolvedPlugins;
    };
in
fmt.generate name yamlValue
