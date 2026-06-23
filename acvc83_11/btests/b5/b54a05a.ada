-- B54A05A.ADA

-- CHECK THAT NON-DISCRETE (STRING) AND PRIVATE TYPES ARE NOT PERMITTED
--    IN CASE EXPRESSIONS.

-- DAT 1/29/81

PROCEDURE B54A05A IS

     S1 : CONSTANT STRING (1 .. 1) := "A";

     PACKAGE P IS
          TYPE T IS PRIVATE;
          TYPE LT IS LIMITED PRIVATE;
          VT : CONSTANT T;
          VLT : CONSTANT LT;
     PRIVATE
          TYPE T IS ('Z', X);
          TYPE LT IS NEW INTEGER RANGE 0 .. 1;
          VT : CONSTANT T := X;
          VLT : CONSTANT LT := 0;
     END P;
     USE P;

BEGIN
     CASE INTEGER'(3) IS      -- OK.
          WHEN OTHERS => NULL;
     END CASE;

     CASE S1 IS               -- ERROR: STRING TYPE.
          WHEN OTHERS => NULL;
     END CASE;

     CASE VT IS               -- ERROR: PRIVATE TYPE.
          WHEN OTHERS => NULL;
     END CASE;

     CASE VLT IS              -- ERROR: PRIVATE TYPE.
          WHEN OTHERS => NULL;
     END CASE;

END B54A05A;
