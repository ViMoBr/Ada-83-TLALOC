-- B35A08A.ADA

-- OBJECTIVE:
--     CHECK THAT THE MULTIPLICATION AND DIVISION OPERATORS FOR ONE
--     FIXED POINT OPERAND AND ONE INTEGER OPERAND ARE NOT DIRECTLY
--     VISIBLE.

-- HISTORY:
--     BCB 01/21/88  CREATED ORIGINAL TEST.

PROCEDURE B35A08A IS

     PACKAGE P IS
          TYPE T IS DELTA 0.25 RANGE -100.0 .. 100.0;
     END P;

     X1 : P.T := 1.0;
     X2 : P.T := 2.0;
     X3 : P.T := 2 * X1;                               -- ERROR:
     X4 : P.T := X2 * 3;                               -- ERROR:
     X5 : P.T := X1 / 2;                               -- ERROR:

BEGIN
     NULL;
END B35A08A;
