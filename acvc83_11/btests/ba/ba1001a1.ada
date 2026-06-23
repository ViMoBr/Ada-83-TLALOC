-- BA1001A1.ADA

-- OBJECTIVE:
--     CHECK THAT A SUBPROGRAM CANNOT BE COMPILED AS A LIBRARY UNIT OR
--     SUBUNIT IF ITS DESIGNATOR IS AN OPERATOR SYMBOL.  FILE BA1001A0M
--     MUST BE COMPILED PRIOR TO THIS FILE.

-- HISTORY:
--     JET 03/25/88  CREATED ORIGINAL TEST.

FUNCTION "AND" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END "AND";

FUNCTION "OR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END "OR";

FUNCTION "XOR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END "XOR";

WITH BA1001A0M; USE BA1001A0M;
FUNCTION "=" (LEFT, RIGHT: LIM) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END "=";

FUNCTION "<" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END "<";

FUNCTION "<=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END "<=";

FUNCTION ">" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END ">";

FUNCTION ">=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN FALSE;
END ">=";

FUNCTION "+" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "+";

FUNCTION "-" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "-";

FUNCTION "&" (LEFT, RIGHT: STRING) RETURN STRING IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN "HOWDY";
END "&";

FUNCTION "+" (RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "+";

FUNCTION "-" (RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "-";

FUNCTION "*" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "*";

FUNCTION "/" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "/";

FUNCTION "MOD" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                       -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "MOD";

FUNCTION "REM" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                       -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "REM";

FUNCTION "**" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                       -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "**";

FUNCTION "ABS" (RIGHT: INTEGER) RETURN INTEGER IS
                                       -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN 0;
END "ABS";

FUNCTION "NOT" (RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                       -- ERROR: OPERATOR SYMBOL.
BEGIN
     RETURN TRUE;
END "NOT";


WITH BA1001A0M; USE BA1001A0M;
PACKAGE BA1001A1 IS
     FUNCTION "AND" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN;
     FUNCTION "OR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN;
     FUNCTION "XOR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN;
     FUNCTION "=" (LEFT, RIGHT: LIM) RETURN BOOLEAN;
     FUNCTION "<" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN;
     FUNCTION "<=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN;
     FUNCTION ">" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN;
     FUNCTION ">=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN;
     FUNCTION "+" (LEFT, RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "-" (LEFT, RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "&" (LEFT, RIGHT: STRING) RETURN STRING;
     FUNCTION "+" (RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "-" (RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "*" (LEFT, RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "/" (LEFT, RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "MOD" (LEFT, RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "REM" (LEFT, RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "**" (LEFT, RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "ABS" (RIGHT: INTEGER) RETURN INTEGER;
     FUNCTION "NOT" (RIGHT: BOOLEAN) RETURN BOOLEAN;
END BA1001A1;

WITH BA1001A0M; USE BA1001A0M;
PACKAGE BODY BA1001A1 IS
     FUNCTION "AND" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "OR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "XOR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "=" (LEFT, RIGHT: LIM) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "<" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "<=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION ">" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION ">=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "+" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "-" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "&" (LEFT, RIGHT: STRING) RETURN STRING IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "+" (RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "-" (RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "*" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "/" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "MOD" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "REM" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "**" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "ABS" (RIGHT: INTEGER) RETURN INTEGER IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
     FUNCTION "NOT" (RIGHT: BOOLEAN) RETURN BOOLEAN IS SEPARATE;
                                        -- ERROR: OPERATOR SYMBOL.
END BA1001A1;


SEPARATE (BA1001A1)
FUNCTION "AND" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "AND" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END "AND";

SEPARATE (BA1001A1)
FUNCTION "OR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "OR" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END "OR";

SEPARATE (BA1001A1)
FUNCTION "XOR" (LEFT, RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "XOR" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END "XOR";

WITH BA1001A0M; USE BA1001A0M;
SEPARATE (BA1001A1)
FUNCTION "=" (LEFT, RIGHT: LIM) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "=" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END "=";

SEPARATE (BA1001A1)
FUNCTION "<" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "<" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END "<";

SEPARATE (BA1001A1)
FUNCTION "<=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "<=" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END "<=";

SEPARATE (BA1001A1)
FUNCTION ">" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF ">" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END ">";

SEPARATE (BA1001A1)
FUNCTION ">=" (LEFT, RIGHT: INTEGER) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF ">=" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN FALSE;
END ">=";

SEPARATE (BA1001A1)
FUNCTION "+" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "+" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "+";

SEPARATE (BA1001A1)
FUNCTION "-" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "-" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "-";

SEPARATE (BA1001A1)
FUNCTION "&" (LEFT, RIGHT: STRING) RETURN STRING IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "&" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN "HOWDY";
END "&";

SEPARATE (BA1001A1)
FUNCTION "+" (RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "+" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "+";

SEPARATE (BA1001A1)
FUNCTION "-" (RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "-" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "-";

SEPARATE (BA1001A1)
FUNCTION "*" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "*" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "*";

SEPARATE (BA1001A1)
FUNCTION "/" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "/" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "/";

SEPARATE (BA1001A1)
FUNCTION "MOD" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "MOD" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "MOD";

SEPARATE (BA1001A1)
FUNCTION "REM" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "REM" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "REM";

SEPARATE (BA1001A1)
FUNCTION "**" (LEFT, RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "**" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "**";

SEPARATE (BA1001A1)
FUNCTION "ABS" (RIGHT: INTEGER) RETURN INTEGER IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "ABS" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN 0;
END "ABS";

SEPARATE (BA1001A1)
FUNCTION "NOT" (RIGHT: BOOLEAN) RETURN BOOLEAN IS
                                        -- ERROR: OPERATOR SYMBOL.
                                        --    OPTIONAL IF "NOT" STUB IS
                                        --    FLAGGED AS ERROR.
BEGIN
     RETURN TRUE;
END "NOT";
