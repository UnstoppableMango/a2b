{
  buildGoApplication,
  ginkgo,
  lib,
  nodejs,
  petstore,
  ux,
}:
buildGoApplication {
  pname = "a2b";
  version = "0.0.1";
  src = lib.cleanSource ./..;
  modules = ./gomod2nix.toml;

  nativeCheckInputs = [
    ginkgo
    nodejs
  ];

  PETSTORE_PATH = petstore;

  checkPhase = ''
    ginkgo run -r .
  '';
}
