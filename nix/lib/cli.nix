{ lib }:
{
  optionalArg =
    flag: val: lib.optionalString (val != null) "--${flag}=${lib.escapeShellArg "${val}"}";

  boolArg = flag: val: lib.optionalString (val != null) "--${flag}=${lib.boolToString val}";

  listArg =
    flag: val:
    lib.optionalString (val != null) "--${flag}=${lib.escapeShellArg (lib.concatStringsSep "," val)}";

  repeatArg = flag: list: lib.concatMapStringsSep " " (x: "--${flag}=${lib.escapeShellArg x}") list;
}
