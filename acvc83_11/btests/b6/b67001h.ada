-- B67001H.ADA

-- OBJECTIVE:
--     CHECK THAT A PROCEDURE DECLARATION WITH THE OPERATOR SYMBOL
--     ":=" IS NOT ALLOWED.

-- HISTORY:
--     DWC 09/22/87  CREATED ORIGINAL TEST FROM SPLIT OF B67001A.ADA.

PROCEDURE B67001H IS

     PACKAGE P IS
          TYPE LIM_PRIV IS LIMITED PRIVATE;
          PROCEDURE ":=" (L : OUT LIM_PRIV; R : IN LIM_PRIV);  -- ERROR:
                                                               -- :=
     PRIVATE
          TYPE LIM_PRIV IS NEW INTEGER;
     END P;
     USE P;

     PACKAGE BODY P IS
          PROCEDURE ":=" (L : OUT LIM_PRIV; R : IN LIM_PRIV) IS-- ERROR:
                                                               -- :=
          BEGIN
               L := R;
          END ":=";
     END P;

BEGIN

     NULL;

END B67001H;
