{
  bash,
  crdRootGroup ? "crossplane.io",
  fetchFromGitHub,
  git,
  lib,
  mangoTools,
  pname ? "upjet-provider-${providerNameLower}",
  providerName,
  providerNameLower ? lib.strings.toLower providerName,
  organizationName,
  stdenvNoCC,
  terraformProviderSource ? "hashicorp/${providerNameLower}",
  terraformProviderRepo ? "https://github.com/hashicorp/terraform-provider-${providerNameLower}",
  terraformProviderVersion,
  terraformProviderDownloadName ? "terraform-provider-${providerNameLower}",
  terraformNativeProviderBinary ? "terraform-provider-${providerNameLower}_v${terraformProviderVersion}",
  terraformDocsPath ? "docs/resources",
  version,
  ...
}:
let
  src = fetchFromGitHub {
    owner = "crossplane";
    repo = "upjet-provider-template";
    rev = "96440083ef6ed070d9413436a9d6a40000d6773f";
    hash = "sha256-OhXPzgzaXmaWsgFow1wocyMoFY4Apb7Lj552I248l50=";
    fetchSubmodules = true;
  };
in
stdenvNoCC.mkDerivation {
  # https://github.com/crossplane/upjet/blob/main/docs/generating-a-provider.md
  inherit pname version src;

  patches = [ ./Makefile.patch ];
  nativeBuildInputs = [ git ];

  PROVIDER_NAME_LOWER = providerNameLower;
  PROVIDER_NAME_NORMAL = providerName;
  ORGANIZATION_NAME = organizationName;
  CRD_ROOT_GROUP = crdRootGroup;

  # This is terrible, but feels less error-prone than translating `git grep` to `grep`
  preConfigure = ''
    patchShebangs hack/prepare.sh
    git init -b main && git add .
  '';

  configurePhase = ''
    runHook preConfigure

    hack/prepare.sh
    rm -rf internal/controller/cluster/null
    rm -rf internal/controller/namespaced/null

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    substituteInPlace Makefile \
      --subst-var-by 'TERRAFORM_PROVIDER_SOURCE' '${terraformProviderSource}' \
      --subst-var-by 'TERRAFORM_PROVIDER_REPO' '${terraformProviderRepo}' \
      --subst-var-by 'TERRAFORM_PROVIDER_VERSION' '${terraformProviderVersion}' \
      --subst-var-by 'TERRAFORM_PROVIDER_DOWNLOAD_NAME' '${terraformProviderDownloadName}' \
      --subst-var-by 'TERRAFORM_NATIVE_PROVIDER_BINARY' '${terraformNativeProviderBinary}' \
      --subst-var-by 'TERRAFORM_DOCS_PATH' '${terraformDocsPath}'

    substituteInPlace build/makelib/common.mk \
      --replace '/usr/bin/env bash' '${bash}/bin/bash'

    runHook postBuild
  '';

  installPhase = ''
    cp -r . $out
  '';

  passthru.update-deps = mangoTools.mkUpdateDeps src;
}
