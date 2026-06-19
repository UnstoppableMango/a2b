{
  pkgs,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
let
  lib = pkgs.lib.extend (
    final: prev: {
      strings = import ./strings.nix { lib = prev; };
      cli = import ./cli.nix { lib = prev; };
    }
  );
in
{
  inherit lib;
  inherit (lib) cli strings;

  buf = pkgs.callPackage ./buf { };
  flux = pkgs.callPackage ./flux { };
  kube-vip = pkgs.callPackage ./kube-vip { };

  terraform = pkgs.callPackage ./terraform {
    inherit lib terraform-plugin-codegen-framework terraform-plugin-codegen-openapi;
  };

  typescript = pkgs.callPackage ./typescript { };

  upjet = pkgs.callPackage ./upjet { };
}
