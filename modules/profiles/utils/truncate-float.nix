lib:

let
  trunc = float: if float < 0 then builtins.ceil float else builtins.floor float;
  pow = base: exp: builtins.foldl' builtins.mul 1 (builtins.genList (_: base) exp);
  truncateFloat = float: precision: trunc (float * pow 10 precision) / pow 10.0 precision;
in
truncateFloat
