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
{ formats, lib }:
{
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
        rest = removeAttrs plugin [
          "package"
          "bin"
        ];
      in
      rest // { local = if plugin ? bin then "${pkg}/bin/${plugin.bin}" else lib.getExe pkg; }
    else
      plugin;

  resolvedPlugins = map resolvePlugin plugins;

  yamlValue =
    removeAttrs attrs [
      "inputs"
      "name"
      "plugins"
    ]
    // {
      version = attrs.version or "v2";
      plugins = resolvedPlugins;
    }
    # An `inputs` key competes with the input argument and --path passed on the
    # command line, so only emit it when the caller actually configured one.
    // lib.optionalAttrs (inputs != [ ]) { inherit inputs; };
in
fmt.generate name yamlValue
