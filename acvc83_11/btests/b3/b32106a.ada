-- B32106A.ADA

-- CHECK THAT OBJECTS DECLARED WITH ARRAY_TYPE_DEFINITIONS HAVE DISTINCT
-- TYPES, EVEN WHEN THE OBJECTS ARE DECLARED IN THE SAME OBJECT
-- DECLARATION

-- DAT 3/17/81
-- JBG 12/17/82

PROCEDURE B32106A IS

     A : ARRAY (BOOLEAN) OF BOOLEAN;
     B : ARRAY (BOOLEAN) OF BOOLEAN;
     C, D : ARRAY (BOOLEAN) OF BOOLEAN;

BEGIN

     A := B;                                 -- ERROR: TYPE MISMATCH.
     A := (TRUE, TRUE);                      -- OK.
     IF A = B THEN                           -- ERROR: TYPE MISMATCH.
          NULL;
     END IF;

     C := D;                                 -- ERROR: TYPE MISMATCH.
     C(TRUE) := (C = D);                     -- ERROR: TYPE MISMATCH.

END B32106A;
