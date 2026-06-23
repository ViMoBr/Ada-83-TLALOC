-- B67001I.ADA

-- OBJECTIVE:
--     CHECK THAT A PROCEDURE DECLARATION WITH OPERATOR SYMBOL
--     ":=" IS NOT ALLOWED AS A GENERIC FORMAL SUBPROGRAM PARAMETER.

-- HISTORY::
--     DWC 09/22/87  CREATED ORIGINAL TEST FROM SPLIT OF B67001B.ADA.

PROCEDURE B67001I IS
     PACKAGE P IS
          TYPE LIM_PRIV IS LIMITED PRIVATE;
     PRIVATE
          TYPE LIM_PRIV IS NEW INTEGER;
     END P;
     USE P;
BEGIN

     --------------------------------------------------

     DECLARE -- (A)
          GENERIC

               WITH PROCEDURE ":=" (I1 : OUT INTEGER;      -- ERROR: :=
                                    I2 : INTEGER);

          PACKAGE PKG IS
          END PKG;

     BEGIN -- (A)
          NULL;
     END; -- (A)

END B67001I;
