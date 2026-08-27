{
  pkgs,
  gossamer,
  pulumi2nixLib,
  pulumiPackages,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
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

  # Builders from UnstoppableMango/pulumi2nix, whose flake.lib is a `{ pkgs }:`
  # function rather than an attrset.
  pulumi = pulumi2nixLib { inherit pkgs; };

  # Provider plugins, language runtimes, and components from unmango/pulumipkgs.
  inherit pulumiPackages;

  terraform = pkgs.callPackage ./terraform {
    inherit lib terraform-plugin-codegen-framework terraform-plugin-codegen-openapi;
  };

  tree-sitter = pkgs.callPackage ./tree-sitter { };
  typescript = pkgs.callPackage ./typescript { };
  upjet = pkgs.callPackage ./upjet { };
}
