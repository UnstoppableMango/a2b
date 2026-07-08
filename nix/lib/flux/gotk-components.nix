{
  createSourceGit,
  createKustomization,
  install,
  runCommand,
}:
{
  branch ? null,
  components ? null,
  componentsExtra ? null,
  env ? { },
  interval ? null,
  name ? "flux-gotk-components",
  namespace ? null,
  path,
  semver ? null,
  syncName ? null,
  tag ? null,
  url,
}:
let
  ns = if namespace != null then namespace else "flux-system";
  sn = if syncName != null then syncName else ns;

  componentsDrv = install {
    inherit
      components
      componentsExtra
      ;
    namespace = ns;
    name = "${name}-install";
  };

  sourceDrv = createSourceGit {
    inherit
      url
      branch
      tag
      semver
      interval
      ;
    namespace = ns;
    name = sn;
  };

  kstnDrv = createKustomization {
    inherit
      path
      interval
      ;
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
