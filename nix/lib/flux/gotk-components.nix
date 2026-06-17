{
  branch ? null,
  components ? null,
  componentsExtra ? null,
  env ? { },
  fluxcd,
  interval ? null,
  lib,
  name ? "flux-gotk-components",
  namespace ? null,
  path,
  runCommand,
  semver ? null,
  syncName ? null,
  tag ? null,
  url,
}:
let
  ns = if namespace != null then namespace else "flux-system";
  sn = if syncName != null then syncName else ns;

  install = import ./install.nix;
  createSourceGit = import ./create-source-git.nix;
  createKustomization = import ./create-kustomization.nix;

  componentsDrv = install {
    inherit fluxcd lib runCommand components componentsExtra;
    namespace = ns;
    name = "${name}-install";
  };

  sourceDrv = createSourceGit {
    inherit fluxcd lib runCommand url branch tag semver interval;
    namespace = ns;
    name = sn;
  };

  kstnDrv = createKustomization {
    inherit fluxcd lib runCommand path interval;
    namespace = ns;
    name = sn;
    source = "GitRepository/${sn}";
    prune = true;
  };

  kustomizationYaml = builtins.toFile "kustomization.yaml" ''
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:
    - gotk-components.yaml
    - gotk-sync.yaml
  '';
in
runCommand name env ''
  mkdir $out
  cp ${componentsDrv} $out/gotk-components.yaml
  cat ${sourceDrv} ${kstnDrv} > $out/gotk-sync.yaml
  cp ${kustomizationYaml} $out/kustomization.yaml
''
