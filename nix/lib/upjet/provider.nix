{
  buildGoApplication,
  buildProviderRepo,
  lib,
  coreutils,
  curlMinimal,
  git,
  gnumake,
  gotools,
  inetutils,
  mangoTools,
  modules,
  terraform,
  pname,
  version,
  ...
}@attrs:
let
  repo = buildProviderRepo (
    {
      inherit pname version;
    }
    // attrs
  );
in
buildGoApplication {
  inherit
    pname
    version
    modules
    ;

  passthru.update-deps = mangoTools.mkUpdateDeps repo;
  src = repo;

  nativeBuildInputs = [
    coreutils
    curlMinimal
    git
    gnumake
    gotools
    inetutils
    terraform
  ];

  preBuild = ''
    sed -i '8,10d;36d;60d' config/provider.go
    sed -i '12,15d;21,23d' apis/cluster/zz_register.go
    sed -i '12,15d;21,23d' apis/namespaced/zz_register.go
    sed -i '12d;20d;34d' internal/controller/cluster/zz_setup.go
    sed -i '12d;20d;34d' internal/controller/namespaced/zz_setup.go

    # TODO
    # make generate
  '';
}
