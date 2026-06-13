{
  pkgs,
  terraform-plugin-codegen-framework,
  terraform-plugin-codegen-openapi,
}:
let
  strings = pkgs.callPackage ./strings.nix { };
in
{
  inherit strings;

  terraform = pkgs.callPackage ./terraform {
    inherit terraform-plugin-codegen-framework;
    inherit terraform-plugin-codegen-openapi;
    inherit strings;
  };
}
