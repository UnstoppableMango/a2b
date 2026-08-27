# Modules in a v2 workspace resolve imports between each other, so listing a
# vendored tree here is enough to make it importable: no `deps`, no buf.lock,
# no network at build time.
{
  formats,
  lib,
  runCommand,
}:
{
  env ? { },
  modules,
  name ? "buf-workspace",
  ...
}@attrs:
let
  fmt = formats.yaml { };

  vendorPaths = map (m: m.path) (builtins.filter (m: m.vendor or false) modules);

  # Vendored protos are third-party; lint and breaking checks on them are noise.
  ignoreAttrs =
    key:
    let
      existing = attrs.${key} or { };
    in
    lib.optionalAttrs (vendorPaths != [ ]) {
      ${key} = existing // {
        ignore = (existing.ignore or [ ]) ++ vendorPaths;
      };
    };

  yamlValue =
    removeAttrs attrs [
      "env"
      "modules"
      "name"
    ]
    // {
      version = attrs.version or "v2";
      modules = map (
        m:
        removeAttrs m [
          "src"
          "vendor"
        ]
      ) modules;
    }
    // ignoreAttrs "lint"
    // ignoreAttrs "breaking";

  bufYaml = fmt.generate "buf.yaml" yamlValue;

  copyModule = m: ''
    mkdir -p "$out/$(dirname ${lib.escapeShellArg m.path})"
    cp -R --no-preserve=mode ${m.src} "$out/${m.path}"
  '';
in
runCommand name env ''
  runHook preRun

  mkdir -p "$out"
  ${lib.concatMapStringsSep "\n" copyModule modules}
  cp ${bufYaml} "$out/buf.yaml"

  runHook postRun
''
