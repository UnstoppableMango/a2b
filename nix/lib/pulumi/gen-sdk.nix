{
  lib,
  pulumi,
  pulumiPackages,
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
  # Known nixpkgs pulumi language plugins; languages without one (dotnet, java, yaml, ...)
  # must be supplied via `plugins`.
  knownLanguagePlugins = {
    go = pulumiPackages.pulumi-go;
    nodejs = pulumiPackages.pulumi-nodejs;
    python = pulumiPackages.pulumi-python;
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
