-- BC1206A.ADA

-- CHECK THAT AN UNCONSTRAINED FORMAL TYPE WITH DISCRIMINANTS IS NOT 
-- ALLOWED AS THE PARENT TYPE IN THE FULL DECLARATION OF A PRIVATE
-- TYPE.

-- R.WILLIAMS 9/25/86

PROCEDURE BC1206A IS
     
     GENERIC
          TYPE FORM (D : INTEGER) IS PRIVATE;
     PACKAGE PKG IS
          TYPE PRIV1 (D : INTEGER) IS PRIVATE;
          TYPE PRIV2 IS PRIVATE;
          TYPE PRIV3 IS PRIVATE;

     PRIVATE 
          TYPE PRIV1 (D : INTEGER) IS NEW FORM;     -- ERROR: 
                                                    -- UNCONSTRAINED.
          TYPE PRIV2 IS NEW FORM;                   -- ERROR: 
                                                    -- UNCONSTRAINED.
          TYPE PRIV3 IS NEW FORM (5);               -- OK.
     END PKG;

BEGIN
     NULL;
END BC1206A;
