-- B83012B.ADA

-- OBJECTIVE:
--     CHECK THAT WITHIN A SINGLE ENTRY OR ENTRY FAMILY NO DECLARATION
--     OF THE IDENTIFIER OF THE ENTRY OR ENTRY FAMILY IS VISIBLE, EITHER
--     DIRECTLY OR BY SELECTION.

-- HISTORY:
--     JET 07/25/88  CREATED ORIGINAL TEST.

PROCEDURE B83012B IS
     TYPE ENTRY1 IS RANGE -100 .. 100;
     SUBTYPE ENTRY2 IS INTEGER;
     ENTRY3 : INTEGER := 1;
     ENTRY4 : INTEGER := 2;

     TYPE EREC IS RECORD
          ENTRY5 : INTEGER;
          ENTRY7 : INTEGER;
     END RECORD;

     TYPE FREC IS RECORD
          ENTRY6 : INTEGER;
          ENTRY8 : INTEGER;
     END RECORD;

     ER : EREC := (1,1);
     FR : FREC := (2,2);

     PACKAGE EPACK IS
          TYPE ENTRY9 IS NEW INTEGER;
          TYPE ENTRY10 IS RANGE -100..100;
     END EPACK;

     FUNCTION EFUNK (ENTRY11 : INTEGER := 1;
                     ENTRY12 : INTEGER := 1) RETURN INTEGER;

     TASK THE_TASK IS
     ENTRY ENTRY1 (I : ENTRY1);
                                          -- ERROR: ENTRY1 UNDENOTABLE.
          ENTRY ENTRY2 (1..2) (I : ENTRY2);
                                          -- ERROR: ENTRY2 UNDENOTABLE.
          ENTRY ENTRY3 (I : INTEGER := ENTRY3);
                                          -- ERROR: ENTRY3 UNDENOTABLE.
          ENTRY ENTRY4 (1..2) (I : INTEGER := ENTRY4);
                                          -- ERROR: ENTRY4 UNDENOTABLE.
          ENTRY ENTRY5 (I : INTEGER := ER.ENTRY5);
                                          -- ERROR: ENTRY5 UNDENOTABLE.
          ENTRY ENTRY6 (1..2) (I : INTEGER := FR.ENTRY6);
                                          -- ERROR: ENTRY6 UNDENOTABLE.
          ENTRY ENTRY7 (I : EREC := (0, ENTRY7 => 1));
                                          -- ERROR: ENTRY7 UNDENOTABLE.
          ENTRY ENTRY8 (1..2) (I : FREC := (0, ENTRY8 => 1));
                                          -- ERROR: ENTRY8 UNDENOTABLE.
          ENTRY ENTRY9 (I : EPACK.ENTRY9);
                                          -- ERROR: ENTRY9 UNDENOTABLE.
          ENTRY ENTRY10(1..2) (I : EPACK.ENTRY10);
                                          -- ERROR: ENTRY10 UNDENOTABLE.
          ENTRY ENTRY11(I : INTEGER := EFUNK(ENTRY11 => 0));
                                          -- ERROR: ENTRY11 UNDENOTABLE.
          ENTRY ENTRY12(1..2) (I : INTEGER := EFUNK(ENTRY12 => 0));
                                          -- ERROR: ENTRY12 UNDENOTABLE.
     END THE_TASK;

     PACKAGE ENTRY13 IS
          SUBTYPE INT IS INTEGER;
          TASK TASK13 IS
               ENTRY ENTRY13(I : ENTRY13.INT);
                                          -- ERROR: ENTRY13 UNDENOTABLE.
          END TASK13;
     END ENTRY13;

     PACKAGE ENTRY14 IS
          TYPE INT IS NEW INTEGER;
          TASK TASK14 IS
               ENTRY ENTRY14(1..2) (I : ENTRY14.INT);
                                          -- ERROR: ENTRY14 UNDENOTABLE.
          END TASK14;
     END ENTRY14;

     FUNCTION EFUNK (ENTRY11 : INTEGER := 1;
                     ENTRY12 : INTEGER := 1) RETURN INTEGER IS
     BEGIN
          RETURN 0;
     END EFUNK;

     TASK BODY THE_TASK IS
     BEGIN
          NULL;
     END THE_TASK;

     PACKAGE BODY ENTRY13 IS
          TASK BODY TASK13 IS
          BEGIN
               NULL;
          END TASK13;
     END ENTRY13;

     PACKAGE BODY ENTRY14 IS
          TASK BODY TASK14 IS
          BEGIN
               NULL;
          END TASK14;
     END ENTRY14;

BEGIN
     NULL;
END B83012B;
