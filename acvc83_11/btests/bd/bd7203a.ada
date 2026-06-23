-- BD7203A.ADA

-- OBJECTIVE:
--     CHECK THAT THE PREFIX OF THE 'SIZE ATTRIBUTE CANNOT BE A
--     SUBPROGRAM, GENERIC UNIT, PACKAGE, NAMED NUMBER, LABEL, ENTRY,
--     ENTRY FAMILY, EXCEPTION, OR AN ATTRIBUTE OTHER THAN T'BASE.

-- HISTORY:
--     JET 08/24/88  CREATED ORIGINAL TEST.

PROCEDURE BD7203A IS

     I : INTEGER;

     GENERIC
     PROCEDURE GPROC;

     PACKAGE PACK IS
          J : INTEGER;
     END PACK;

     C : CONSTANT := 0;

     TASK T IS
          ENTRY E;
          ENTRY F(1..3);
     END T;

     PROCEDURE PROC IS
     BEGIN
          NULL;
     END PROC;

     PROCEDURE GPROC IS
     BEGIN
          NULL;
     END GPROC;

     TASK BODY T IS
     BEGIN
          ACCEPT E DO
               NULL;
          END E;
          ACCEPT F(1) DO
               NULL;
          END F;
     END T;

BEGIN
<<START_LABEL>>
     I := PROC'SIZE;                    -- ERROR: SUPROGRAM.
     I := GPROC'SIZE;                   -- ERROR: GENERIC UNIT.
     I := PACK'SIZE;                    -- ERROR: PACKAGE.
     I := C'SIZE;                       -- ERROR: NAMED NUMBER.
     I := START_LABEL'SIZE;             -- ERROR: LABEL.
     I := T.E'SIZE;                     -- ERROR: ENTRY.
     I := T.F'SIZE;                     -- ERROR: ENTRY FAMILY.
     I := CONSTRAINT_ERROR'SIZE;        -- ERROR: EXCEPTION.
     I := INTEGER'FIRST'SIZE;           -- ERROR: ATTRIBUTE.
END BD7203A;
