# pulumi2nix's lib and pulumipkgs' overlay are system-independent, so they come
# off the top level `inputs`, which flake-parts does not pass into perSystem.
{ inputs, ... }:
{
  perSystem =
    {
      config,
      inputs',
      lib,
      pkgs,
      ...
    }:
    let
      a2b = config.legacyPackages.lib;
      inherit (inputs'.mangopkgs.legacyPackages) unifiedPackages;
      inherit (inputs'.mangopkgs.packages) gossamer;
    in
    {
      legacyPackages.lib = pkgs.callPackage ./. {
        inherit (inputs'.mangopkgs.packages)
          gossamer
          likec4
          openapi-typescript
          terraform-plugin-codegen-framework
          terraform-plugin-codegen-openapi
          ;

        # mangopkgs only packages kube-vip for Linux.
        kube-vip =
          inputs'.mangopkgs.packages.kube-vip
            or (throw "a2b: kube-vip is not packaged for ${pkgs.stdenv.hostPlatform.system}");

        # openapi2go packages itself rather than going through mangopkgs.
        inherit (inputs'.openapi2go.packages) openapi2go;

        pulumi2nixLib = inputs.pulumi2nix.lib;

        inherit unifiedPackages;

        # Explicit because callPackage would otherwise fill in nixpkgs' own,
        # much smaller, pulumiPackages.
        inherit (pkgs.extend inputs.pulumipkgs.overlays.default) pulumiPackages;
      };

      checks = {
        # Forces legacyPackages.lib to evaluate. Attrs from external inputs stay
        # lazy error thunks until a derivation is actually built.
        lib = pkgs.writeText "lib-check" (builtins.toJSON (builtins.attrNames a2b));

        buf-workspace = pkgs.callPackage ./buf/checks/workspace { inherit a2b; };

        flux = pkgs.callPackage ./flux/checks { inherit a2b; };

        gossamer = pkgs.callPackage ./gossamer/checks { inherit a2b gossamer; };

        likec4-model = pkgs.callPackage ./likec4/checks/model { inherit a2b; };

        openapi2go = pkgs.callPackage ./openapi2go/checks { inherit a2b; };

        terraform = pkgs.callPackage ./terraform/checks { inherit a2b; };

        tree-sitter = pkgs.callPackage ./tree-sitter/checks { inherit a2b; };

        typescript = pkgs.callPackage ./typescript/checks { inherit a2b; };

        unified-run = pkgs.callPackage ./unified/checks { inherit a2b unifiedPackages; };
        unified-lint = pkgs.callPackage ./unified/checks/lint.nix { inherit a2b unifiedPackages; };
        unified-rehype = pkgs.callPackage ./unified/checks/rehype.nix { inherit a2b; };

        upjet = pkgs.callPackage ./upjet/checks { inherit a2b; };

        # Runs on every system under --all-systems, catching a renamed pulumi2nix
        # builder that the native-only build below would miss.
        pulumi-lib = pkgs.writeText "pulumi-lib-check" (builtins.toJSON (builtins.attrNames a2b.pulumi));

        # Cheapest package that still runs mkTerraformBridgeProvider end to end.
        pulumi-random = a2b.pulumiPackages.random;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        kube-vip = pkgs.callPackage ./kube-vip/checks { inherit a2b; };
      };
    };
}
