# flake-parts module exposing the builders as legacyPackages.lib, along with the
# checks that exercise them. Checks live next to the builder they cover, e.g.
# nix/lib/buf/checks/.
{
  perSystem =
    {
      config,
      inputs',
      pkgs,
      ...
    }:
    let
      a2b = config.legacyPackages.lib;
    in
    {
      legacyPackages.lib = pkgs.callPackage ./. {
        inherit (inputs'.mangopkgs.packages)
          gossamer
          terraform-plugin-codegen-framework
          terraform-plugin-codegen-openapi
          ;
      };

      checks = {
        # Forces legacyPackages.lib to evaluate, catching import errors and wrong
        # function signatures. Does NOT catch missing attrs from external inputs;
        # those propagate as lazy error thunks until a derivation is actually built.
        lib = pkgs.writeText "lib-check" (builtins.toJSON (builtins.attrNames a2b));

        buf-workspace = pkgs.callPackage ./buf/checks/workspace { inherit a2b; };
      };
    };
}
