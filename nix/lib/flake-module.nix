# Exposes the builders as legacyPackages.lib. pulumi2nix's lib and pulumipkgs'
# overlay are system-independent, so they come off the top level `inputs`, which
# flake-parts does not pass into perSystem.
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

        # Explicit because callPackage would otherwise fill in nixpkgs' own,
        # much smaller, pulumiPackages.
        inherit (pkgs.extend inputs.pulumipkgs.overlays.default) pulumiPackages;
      };

      checks = {
        # Forces legacyPackages.lib to evaluate. Attrs from external inputs stay
        # lazy error thunks until a derivation is actually built.
        lib = pkgs.writeText "lib-check" (builtins.toJSON (builtins.attrNames a2b));

        buf-workspace = pkgs.callPackage ./buf/checks/workspace { inherit a2b; };

        # Runs on every system under --all-systems, catching a renamed pulumi2nix
        # builder that the native-only build below would miss.
        pulumi-lib = pkgs.writeText "pulumi-lib-check" (builtins.toJSON (builtins.attrNames a2b.pulumi));

        # Cheapest package that still runs mkTerraformBridgeProvider end to end.
        pulumi-random = a2b.pulumiPackages.random;
      };
    };
}
