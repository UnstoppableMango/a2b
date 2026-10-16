{
  a2b,
  gossamer,
  runCommand,
}:
let
  src = runCommand "gossamer-check-src" { } ''
    ${gossamer}/bin/gos new example.com/hello --path $out
  '';

  checked = a2b.gossamer.check {
    name = "gossamer-check-check";
    inherit src;
  };

  built = a2b.gossamer.build {
    name = "gossamer-check-build";
    inherit src;
    release = true;
  };
in
runCommand "gossamer-check" { } ''
  fail() {
    echo "$1" >&2
    exit 1
  }

  [ -e ${checked} ] || fail "check produced no output"

  bins=(${built}/bin/*)
  [ -x "''${bins[0]}" ] || fail "build produced no executable"
  "''${bins[0]}" || fail "built executable did not run"

  touch "$out"
''
