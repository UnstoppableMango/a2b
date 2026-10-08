{
  pkgs,
  gossamer,
  likec4,
  pulumi2nixLib,
  pulumiPackages,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
  unifiedPackages,
}:
let
  lib = pkgs.lib.extend (
    final: prev: {
      a2b.strings = import ./strings.nix { lib = prev; };
      a2b.cli = import ./cli.nix { lib = prev; };
    }
  );
in
{
  buf = pkgs.callPackage ./buf { };
  flux = pkgs.callPackage ./flux { };
  gossamer = pkgs.callPackage ./gossamer { inherit gossamer; };
  kube-vip = pkgs.callPackage ./kube-vip { };
  likec4 = pkgs.callPackage ./likec4 { inherit likec4; };

  # pulumi2nix's flake.lib is a `{ pkgs }:` function rather than an attrset.
  pulumi = pulumi2nixLib { inherit pkgs; };

  inherit pulumiPackages;

  terraform = pkgs.callPackage ./terraform {
    inherit lib terraform-plugin-codegen-framework terraform-plugin-codegen-openapi;
  };

  tree-sitter = pkgs.callPackage ./tree-sitter { };
  typescript = pkgs.callPackage ./typescript { };

  unified = pkgs.callPackage ./unified { inherit unifiedPackages; };

  # Re-exported from unmango/pkgs, like pulumiPackages, so the plugins reach
  # a consumer through a2b alone.
  inherit unifiedPackages;

  upjet = pkgs.callPackage ./upjet { };
}
