-- B54A21A.ADA

-- CHECK THAT NON-STATIC CASE CHOICES ARE FORBIDDEN.

-- DAT 1/29/81
--  RM 6/29/82
-- JBG 5/23/83

PROCEDURE B54A21A IS

     TYPE T IS RANGE 1 .. 10;
     T1 : T RANGE 1 .. 1 := 1;
     T5 : T RANGE 5 .. 5 := 5;
     T10 : T RANGE 10 .. 10 := 10;
     SUBTYPE ST IS T RANGE 10 .. T10;
     SUBTYPE ST1 IS T RANGE T1 .. 1;
     VST : ST RANGE 10 .. 10 := 10;
     C6 : CONSTANT T := 6;
     B  :  BOOLEAN  RANGE TRUE..TRUE  := TRUE ;


BEGIN

     CASE T'(3) IS
          WHEN VST => NULL;                -- ERROR: NON-STATIC CHOICE.
          WHEN 2 => NULL;                  -- OK.
          WHEN ST1 => NULL;                -- ERROR: NON-STATIC CHOICE.
          WHEN T'(3) | 4 => NULL;          -- OK.
          WHEN T RANGE 5 .. T5 => NULL;    -- ERROR: NON-STATIC CHOICE.
          WHEN C6 => NULL;                 -- OK.
          WHEN ST RANGE 10..T10-1 => NULL; -- ERROR: NON-STATIC CHOICE.
          WHEN C6 + 3 - 2 => NULL;         -- OK.
          WHEN VST - 1 .. 9 => NULL;       -- ERROR: NON-STATIC CHOICE.
          WHEN OTHERS => NULL;             -- OK.
     END CASE;


     CASE  TRUE  IS
          WHEN  B       =>  NULL ;         -- ERROR: NON-STATIC CHOICE.
          WHEN  OTHERS  =>  NULL ;         -- OK.
     END CASE;

     CASE  TRUE  IS
          WHEN (TRUE IN BOOLEAN) => NULL; -- ERROR: NON-STATIC OPERATION
          WHEN OTHERS => NULL;
     END CASE;

     CASE TRUE IS
          WHEN BOOLEAN(TRUE) => NULL;      -- ERROR: CONVERSION IS NOT
                                           --   STATIC
          WHEN OTHERS => NULL;
     END CASE;

     CASE T'(3) = 1 IS
          WHEN (TRUE OR ELSE FALSE) 
                              => NULL;   -- ERROR: NON-STATIC OPERATION.
          WHEN (TRUE AND THEN FALSE)
                              => NULL;   -- ERROR: NON-STATIC OPERATION.
          WHEN OTHERS => NULL;
     END CASE;

END B54A21A;
