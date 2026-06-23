-- B45121A.ADA

-- CHECK THAT OPERANDS OF SHORT-CIRCUIT CONTROL FORMS CANNOT HAVE A
-- NON-BOOLEAN TYPE.

-- JWC 08/05/85

PROCEDURE B45121A IS

     TYPE ENUM IS (ENUM1, ENUM2);
     TYPE NEWBOOLEAN IS NEW BOOLEAN;
     TYPE BOOARR IS ARRAY (1 .. 2) OF BOOLEAN;
     E1,E2 : ENUM := ENUM1;
     I1,I2 : INTEGER := 1;
     N1,N2 : NEWBOOLEAN := TRUE;
     BOOARR1, BOOARR2 : BOOARR := (TRUE, FALSE);
     B : BOOLEAN;

     PACKAGE PKG IS
          TYPE PRIV IS PRIVATE;
          PVAL : CONSTANT PRIV;
     PRIVATE
          TYPE PRIV IS NEW BOOLEAN;
          PVAL : CONSTANT PRIV := FALSE;
     END PKG;

     P1, P2 : PKG.PRIV := PKG.PVAL;

BEGIN

     IF I1 AND THEN I2 THEN              -- ERROR: AND THEN INTEGER.
          NULL;
     END IF;

     IF I1 OR ELSE I2 THEN               -- ERROR: OR ELSE INTEGER.
          NULL;
     END IF;

     I1 := I1 AND THEN I2;               -- ERROR: AND THEN INTEGER.

     B := I1 OR ELSE I2;                 -- ERROR: OR ELSE INTEGER.

     IF E1 AND THEN E2 THEN              -- ERROR: AND THEN ENUMERATION.
          NULL;
     END IF;

     IF E1 OR ELSE E2 THEN               -- ERROR: OR ELSE ENUMERATION.
          NULL;
     END IF;

     B := E1 AND THEN E2;                -- ERROR: AND THEN ENUMERATION.

     E1 := E1 OR ELSE E2;                -- ERROR: OR ELSE ENUMERATION.

     IF BOOARR1 AND THEN BOOARR2 THEN    -- ERROR: AND THEN ARRAY.
          NULL;
     END IF;

     IF BOOARR1 OR ELSE BOOARR2 THEN     -- ERROR: OR ELSE ARRAY.
          NULL;
     END IF;

     B := BOOARR1 AND THEN BOOARR2;      -- ERROR: AND THEN ARRAY.

     BOOARR1 := BOOARR1 OR ELSE BOOARR2; -- ERROR: OR ELSE ARRAY.

     IF P1 AND THEN P2 THEN              -- ERROR: AND THEN PRIVATE.
          NULL;
     END IF;

     IF P1 OR ELSE P2 THEN               -- ERROR: OR ELSE PRIVATE.
          NULL;
     END IF;

     B := P1 OR ELSE P2;                 -- ERROR: OR ELSE PRIVATE.

     P1 := P1 AND THEN P2;               -- ERROR: AND THEN PRIVATE.

     IF N1 AND THEN N2 THEN              -- OK.
          NULL;
     END IF;

     IF N1 OR ELSE N2 THEN               -- OK.
          NULL;
     END IF;

     N1 := N1 AND THEN N2;               -- OK.

     B := N1 OR ELSE N2;                 -- ERROR: TYPE MISMATCH.

END B45121A;
