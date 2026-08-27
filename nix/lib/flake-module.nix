# flake-parts module exposing the builders as legacyPackages.lib, along with the
# checks that exercise them. Checks live next to the builder they cover, e.g.
# nix/lib/buf/checks/.
#
# pulumi2nix's lib and pulumipkgs' overlay are system-independent, so they come
# off the top level `inputs`, which flake-parts does not pass into perSystem.
{ inputs, ... }:
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

        pulumi2nixLib = inputs.pulumi2nix.lib;

        # Passed explicitly because nixpkgs carries its own, much smaller,
        # pulumiPackages that callPackage would otherwise fill in here.
        inherit (pkgs.extend inputs.pulumipkgs.overlays.default) pulumiPackages;
      };

      checks = {
        # Forces legacyPackages.lib to evaluate, catching import errors and wrong
        # function signatures. Does NOT catch missing attrs from external inputs;
        # those propagate as lazy error thunks until a derivation is actually built.
        lib = pkgs.writeText "lib-check" (builtins.toJSON (builtins.attrNames a2b));

        buf-workspace = pkgs.callPackage ./buf/checks/workspace { inherit a2b; };

        # Cheap enough to run on every system under --all-systems, which catches
        # a renamed or removed pulumi2nix builder that the native-only smoke
        # build below would miss.
        pulumi-lib = pkgs.writeText "pulumi-lib-check" (builtins.toJSON (builtins.attrNames a2b.pulumi));

        # Proves the pulumipkgs re-export builds rather than merely evaluating.
        # random is the cheapest package in the set that still runs
        # mkTerraformBridgeProvider end to end: gen tool, schema, plugin binary.
        pulumi-random = a2b.pulumiPackages.random;
      };
    };
}
