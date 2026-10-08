# Package sets a2b ships through overlays.default. Each is also exposed under
# legacyPackages so it can be used without applying the overlay.
{ lib, ... }:
{
  flake.overlays.default = final: prev: {
    unifiedPackages = final.callPackage ./unified { };
  };

  perSystem =
    { pkgs, ... }:
    let
      unifiedPackages = pkgs.callPackage ./unified { };
    in
    {
      legacyPackages = { inherit unifiedPackages; };

      packages = { inherit (unifiedPackages) remark-cli; };

      # callPackage adds `override` beside the checks; keep only derivations.
      checks = lib.mapAttrs' (name: lib.nameValuePair "unified-${name}") (
        lib.filterAttrs (_: lib.isDerivation) (
          pkgs.callPackage ./unified/checks { inherit unifiedPackages; }
        )
      );
    };
}
