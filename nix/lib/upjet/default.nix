{
  pkgs,
}:

{
  genProviderTemplate = pkgs.callPackage ./gen-provider-template.nix;
  genProvider = pkgs.callPackage ./gen-provider.nix;
}
