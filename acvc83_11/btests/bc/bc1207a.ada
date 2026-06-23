-- BC1207A.ADA

-- CHECK THAT AN UNCONSTRAINED FORMAL TYPE WITH DISCRIMINANTS IS NOT 
-- ALLOWED IN A VARIABLE DECLARATION, A COMPONENT DECLARATION (OF AN
-- ARRAY OR RECORD), OR AN ALLOCATOR.

-- R.WILLIAMS 9/25/86

PROCEDURE BC1207A IS
     
     GENERIC
          TYPE FORM (D : INTEGER) IS PRIVATE;
          TYPE FARR IS 
                    ARRAY (INTEGER RANGE <>) OF FORM; -- ERROR:
                                                      -- UNCONSTRAINED.
          TYPE FORM_NAME IS ACCESS FORM;             
     PROCEDURE P;

     PROCEDURE P IS
          A : FORM;                                   -- ERROR:
                                                      -- UNCONSTRAINED.
          TYPE REC IS
               RECORD
                    A : FORM;                         -- ERROR:
                                                      -- UNCONSTRAINED.
               END RECORD;

          TYPE ARR IS ARRAY (1 .. 10) OF FORM;        -- ERROR:
                                                      -- UNCONSTRAINED.
          TYPE FORM_NAME1 IS ACCESS FORM (1);

          B : FORM_NAME1 := NEW FORM;                 -- ERROR:
                                                      -- UNCONSTRAINED.
          C : FORM_NAME := NEW FORM;                  -- ERROR:
                                                      -- UNCONSTRAINED.
     BEGIN
          NULL;
     END P;

BEGIN
     NULL;
END BC1207A;
