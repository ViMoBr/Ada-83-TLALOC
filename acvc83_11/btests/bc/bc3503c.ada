-- BC3503C.ADA

-- WHEN A GENERIC FORMAL TYPE FT IS AN ACCESS TYPE AND ITS DESIGNATED
-- TYPE T IS AN ARRAY TYPE OR A TYPE WITH DISCRIMINANTS AND T IS
-- MATCHED BY U, THE DESIGNATED TYPE OF THE ACTUAL PARAMETER, CHECK
-- THAT U MUST BE CONSTRAINED IF AND ONLY IF T IS CONSTRAINED.

-- CHECK WHEN U IS A GENERIC FORMAL TYPE APPEARING IN AN ENCLOSING
-- GENERIC DECLARATION.

-- SPS 5/27/82

PROCEDURE BC3503C IS

     GENERIC
          TYPE U (D : INTEGER) IS PRIVATE;
     PACKAGE PACK IS
          SUBTYPE CU IS U (D => 3);
          TYPE ACU IS ACCESS CU;
          TYPE AU IS ACCESS U;
          SUBTYPE CAU IS AU (D => 3);
          TYPE AUC IS ACCESS U (D => 3);

          GENERIC
               TYPE FT IS ACCESS CU;
          PACKAGE PCU IS END PCU;

          GENERIC
               TYPE FT IS ACCESS U;
          PACKAGE PU IS END PU;

          PACKAGE PCU1 IS NEW PCU (ACU);     -- OK.
          PACKAGE PCU2 IS NEW PCU (AUC);     -- OK.
          PACKAGE PCU3 IS NEW PCU (CAU);     -- OK.
          PACKAGE PCU4 IS NEW PCU (AU);      -- ERROR: U IS NOT
                                             -- CONSTRAINED.   

          PACKAGE PU1 IS NEW PU (ACU);       -- ERROR: ACU IS
                                             -- CONSTRAINED.      
          PACKAGE PU2 IS NEW PU (AUC);       -- ERROR: AUC IS
                                             -- CONSTRAINED.   
          PACKAGE PU3 IS NEW PU (CAU);       -- ERROR: CAU IS
                                             -- CONSTRAINED.   
          PACKAGE PU4 IS NEW PU (AU);        -- OK.

     END PACK;

BEGIN
     NULL;
END BC3503C;
