# Generate a buf.gen.yaml template file.
#
# Plugins with a `package` attr are resolved to `local:` paths automatically;
# all other attrs pass through to the YAML as-is.
#
# Example:
#   buf.mkTemplate {
#     inputs = [{ directory = "."; }];
#     plugins = [
#       { package = pkgs.protoc-gen-go; out = "gen/go"; }
#       { plugin = "buf.build/connectrpc/es"; out = "gen/es"; }
#     ];
#   }
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
