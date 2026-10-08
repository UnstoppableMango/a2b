# The unified.js package set: one derivation per npm package, plus builders
# that run a unified CLI over a source tree. Extend it with `overrideScope`.
{ lib, newScope }:
lib.makeScope newScope (
  self:
  let
    # One fetch and one lockfile for the whole remarkjs/remark monorepo.
    remarkPackages = self.callPackage ./remark { unifiedPackages = self; };
  in
  {
    buildUnifiedWorkspace = self.callPackage ./build-unified-workspace.nix { };
    unifiedRc = self.callPackage ./unified-rc.nix { };
    unifiedRun = self.callPackage ./unified-run.nix { };
    wrapUnifiedCli = self.callPackage ./wrap-unified-cli.nix { };

    inherit (remarkPackages)
      remark
      remark-cli
      remark-parse
      remark-stringify
      ;

    remark-gfm = self.callPackage ./remark-gfm/package.nix { };
  }
)
