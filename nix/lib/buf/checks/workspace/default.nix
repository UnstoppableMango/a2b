# Generates from a two-module workspace where api imports the vendored module.
{
  a2b,
  protoc-gen-go,
  runCommand,
}:
let
  inherit (a2b) buf;

  workspace = buf.mkWorkspace {
    name = "buf-workspace-test";
    modules = [
      {
        path = "third_party/dep";
        vendor = true;
        src = buf.vendor {
          name = "buf-vendor-test-dep";
          src = ./dep;
        };
      }
      {
        path = "api";
        src = ./api;
      }
    ];
  };

  generated = buf.generate {
    name = "buf-workspace-generated";
    src = "${workspace}/api";
    template = buf.mkTemplate {
      plugins = [
        {
          package = protoc-gen-go;
          out = "go";
          opt = [ "paths=source_relative" ];
        }
      ];
    };
  };
in
runCommand "buf-workspace-check" { } ''
  if [ ! -f ${generated}/go/example/api/v1/api.pb.go ]; then
    echo "expected api.pb.go was not generated" >&2
    exit 1
  fi

  if [ -e ${generated}/go/example/dep ]; then
    echo "vendored module leaked into the generated output" >&2
    exit 1
  fi

  touch "$out"
''
