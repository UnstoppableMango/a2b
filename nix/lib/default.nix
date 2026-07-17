{
  pkgs,
  gossamer,
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
  pulumi = pkgs.callPackage ./pulumi { inherit lib; };

  terraform = pkgs.callPackage ./terraform {
    inherit lib terraform-plugin-codegen-framework terraform-plugin-codegen-openapi;
  };

  tree-sitter = pkgs.callPackage ./tree-sitter { };
  typescript = pkgs.callPackage ./typescript { };
  upjet = pkgs.callPackage ./upjet { };
}
