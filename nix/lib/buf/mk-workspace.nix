# Assemble proto trees into a v2 buf workspace directory.
#
# Modules in a workspace resolve imports between each other automatically, so a
# vendored tree becomes importable purely by being listed here. No `deps` entry,
# no buf.lock, and no network access at build time.
#
# Each entry in `modules` is `{ path, src, vendor ? false, ... }`:
#   path   - directory inside the workspace, relative to its root
#   src    - a store path, typically a `buf.vendor` result or the caller's ./proto
#   vendor - adds `path` to the workspace lint and breaking ignore lists
# Any other attr (name, includes, excludes, lint, breaking) passes through to the
# module entry in buf.yaml as-is.
#
# `buf generate` on the workspace root emits code for every module, vendored ones
# included. Point it at a single module directory instead; buf walks up to this
# buf.yaml, so imports still resolve against every other module.
#
# Example:
#   let
#     workspace = buf.mkWorkspace {
#       modules = [
#         { path = "third_party/k8s"; src = k8sProtos; vendor = true; }
#         { path = "proto"; src = ./proto; }
#       ];
#     };
#   in
#   buf.generate {
#     name = "my-protos";
#     src = "${workspace}/proto";
#     template = ...;
#   }
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

  # A vendored module's protos are third-party; linting and breaking-change
  # checks on them are noise.
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
