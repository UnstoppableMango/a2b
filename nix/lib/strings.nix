{ lib }:
{
  toSnakeCase =
    str:
    let
      converted = lib.concatStrings (
        map (
          c:
          let
            lower = lib.toLower c;
          in
          if lower != c then
            "_${lower}"
          else if c == "-" || c == " " then
            "_"
          else
            c
        ) (lib.stringToCharacters (toString str))
      );
    in
    lib.removePrefix "_" converted;
}
