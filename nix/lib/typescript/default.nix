# openapi-typescript itself is packaged in unmango/pkgs.
{ pkgs, openapi-typescript }:
{
  openapi-typescript = pkgs.callPackage ./openapi-typescript.nix { inherit openapi-typescript; };
}
