-- B49008B.ADA

-- CHECK THAT IF AN ENUMERATION LITERAL OR STATIC ATTRIBUTE IS RENAMED 
-- AS A FUNCTION, THE NEW NAME CANNOT BE USED IN A STATIC EXPRESSION.

-- L.BROWN  08/27/86

PROCEDURE  B49008B  IS

     TYPE ENUM IS (A,B,C,D,E,F,G);
     OBJ_ENUM : ENUM := A;
BEGIN
     DECLARE
          FUNCTION FENUM RETURN ENUM RENAMES A;
     BEGIN
          CASE OBJ_ENUM IS
               WHEN FENUM =>                                   -- ERROR:
                    OBJ_ENUM := C;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

     DECLARE
          FUNCTION FSUCC(E : ENUM) RETURN ENUM RENAMES ENUM'SUCC;
     BEGIN
          CASE OBJ_ENUM IS
               WHEN FSUCC(OBJ_ENUM) =>                         -- ERROR:
                    OBJ_ENUM := D;
               WHEN OTHERS =>
                    NULL;
          END CASE;
     END;

END B49008B;
