{ pkgs, terraform-plugin-codegen-openapi }:
{
  terraform = pkgs.callPackage ./terraform { inherit terraform-plugin-codegen-openapi; };
}
