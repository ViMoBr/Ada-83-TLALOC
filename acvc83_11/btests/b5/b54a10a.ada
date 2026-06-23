-- B54A10A.ADA

-- OBJECTIVE:
--     CHECK THAT THE BASE TYPE OF THE CASE EXPRESSION AND THE CHOICE
--     MUST NOT BE DIFFERENT.

-- HISTORY:
--     BCB 02/29/88  CREATED ORIGINAL TEST.

PROCEDURE B54A10A IS

     TYPE X IS NEW INTEGER;

     SUBTYPE INT1 IS INTEGER;

     W : CONSTANT := 100;

     Y : CONSTANT X := 50;

     A : CONSTANT INTEGER := 75;

     C : CONSTANT INT1 := 25;

BEGIN
     CASE Y IS
          WHEN A => NULL;                              -- ERROR:
          WHEN OTHERS => NULL;
     END CASE;

     CASE A IS
          WHEN Y => NULL;                              -- ERROR:
          WHEN OTHERS => NULL;
     END CASE;

     CASE 1_000 IS
          WHEN A => NULL;                              -- ERROR:
          WHEN OTHERS => NULL;
     END CASE;

     CASE W IS
          WHEN A => NULL;                              -- ERROR:
          WHEN OTHERS => NULL;
     END CASE;

     CASE C IS
          WHEN A => NULL;                              -- OK.
          WHEN Y => NULL;                              -- ERROR:
          WHEN OTHERS => NULL;
     END CASE;

END B54A10A;
