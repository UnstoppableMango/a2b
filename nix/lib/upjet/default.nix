{
  pkgs,
}:

{
  genProviderTemplate =
    attrs:
    import ./gen-provider-template.nix (
      {
        inherit (pkgs) lib runCommand;
      }
      // attrs
    );
}
