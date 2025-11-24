-- Control program for compilation of Ada programs
-- can also be used for loading using a flag
--
-- Ton Biegstraaten
-- October, 1987

with CompilerInterface; use CompilerInterface;
with GetArgs; use GetArgs;

with text_io; use text_io;

with integer_io;

procedure ac is
-- to compile: call ac with flags and adaprograms
    VerboseFlag,
    LoadFlag,
    PlFlag,
    BackendFlag,
    DebugFlag	:    boolean	:= FALSE;

    package IntIo is new integer_io (integer);
begin
