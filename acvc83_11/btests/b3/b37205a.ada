-- B37205A.ADA
 
-- CHECK THAT IF A DISCRIMINANT OF A TYPE T IS NAMED A, THEN IN A
-- DISCRIMINANT_SPECIFICATION FOR THE TYPE, T.A CANNOT BE USED AS
-- A NAME FOR THE DISCRIMINANT.
 
-- ASL 7/6/81
-- ABW 6/17/82
-- SPS 2/10/83

PROCEDURE B37205A IS

     TYPE T (A : INTEGER) IS
          RECORD
               STR : STRING (1 .. A);
          END RECORD;

     TYPE T_NAME IS ACCESS T;
 
     SUBTYPE S IS T(T.A => 5);                -- ERROR: T.A.
 
     X : T(T.A => 5);                         -- ERROR: T.A.
 
     Y : T_NAME := NEW T(T.A => 5);           -- ERROR: T.A.
 
BEGIN
     NULL;
END B37205A;
