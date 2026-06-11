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

  # TODO: Need to pre-install openapi-typescript.
  #       Probably use node2nix to tired to figure it out right now.
  #       Its only one test, so not a huge deal
  doCheck = false;

  checkPhase = ''
    ginkgo run -r .
  '';
}
