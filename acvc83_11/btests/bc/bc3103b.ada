-- BC3103B.ADA

-- CHECK THAT COMPONENTS OF A COMPONENT THAT DEPENDS ON A DISCRIMINANT
-- MAY NOT BE ACTUAL GENERIC IN OUT PARAMETERS.

-- DAT 8/14/81

PROCEDURE BC3103B IS
BEGIN
     DECLARE
          GENERIC
               P : IN OUT INTEGER;
          PACKAGE PKG IS END PKG;
          TYPE REC1 IS
               RECORD
                    I : INTEGER;
               END RECORD;
          TYPE REC2 (D : INTEGER := 5) IS
               RECORD
                    CASE D IS 
                         WHEN OTHERS =>
                              C : REC1;
                    END CASE;
               END RECORD;

          R2 : REC2;

          PACKAGE NP IS NEW PKG
               (R2.C.I);                     -- ERROR: DEPENDS ON DISC.

     BEGIN
          NULL;
     END;
END BC3103B;
