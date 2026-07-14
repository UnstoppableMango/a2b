{
  lib,
  pulumi,
  pulumiPackages,
  pulumi-dotnet,
  pulumi-java,
  pulumi-yaml,
  runCommand,
}:
{
  env ? { },
  flags ? [ ],
  language ? null,
  languages ? [ ],
  name,
  plugins ? [ ],
  schema,
  version ? null,
}:
let
  # Known pulumi language plugins: go/nodejs/python from nixpkgs, dotnet/java/yaml
  # from mangopkgs (unmango/pkgs). Other/unknown languages must go via `plugins`.
  knownLanguagePlugins = {
    go = pulumiPackages.pulumi-go;
    nodejs = pulumiPackages.pulumi-nodejs;
    python = pulumiPackages.pulumi-python;
    dotnet = pulumi-dotnet;
    java = pulumi-java;
    yaml = pulumi-yaml;
  };
  requestedLanguages = lib.optional (language != null) language ++ languages;
  languagePlugins = map (
    lang:
    knownLanguagePlugins.${lang} or (throw ''
      pulumi.genSdk: no nixpkgs plugin known for language "${lang}"; pass it via `plugins`
    '')
  ) requestedLanguages;
in
# https://www.pulumi.com/docs/iac/cli/commands/pulumi_package_gen-sdk/
runCommand name env ''
  runHook preRun

  export HOME="$(mktemp -d)"
  export PATH="${lib.makeBinPath (languagePlugins ++ plugins)}:$PATH"

  ${pulumi}/bin/pulumi package gen-sdk \
    --out "$out" \
    ${lib.a2b.cli.optionalArg "language" language} \
    ${lib.a2b.cli.optionalArg "version" version} \
    ${lib.a2b.cli.repeatArg "language" languages} \
    ${lib.escapeShellArgs flags} \
    ${lib.escapeShellArg (toString schema)}

  runHook postRun
''
