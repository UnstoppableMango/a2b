{ lib }:
{
  # --flag=value if val != null (toString coerces paths)
  optionalArg =
    flag: val: lib.optionalString (val != null) "--${flag}=${lib.escapeShellArg (toString val)}";

  # --flag=true|false if val != null
  boolArg = flag: val: lib.optionalString (val != null) "--${flag}=${lib.boolToString val}";

  # --flag=a,b,c if val != null
  listArg =
    flag: val:
    lib.optionalString (val != null) "--${flag}=${lib.escapeShellArg (lib.concatStringsSep "," val)}";

  # --flag=a --flag=b --flag=c
  repeatArg = flag: list: lib.concatMapStringsSep " " (x: "--${flag}=${lib.escapeShellArg x}") list;
}
