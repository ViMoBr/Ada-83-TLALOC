-- B84001A.ADA


-- CHECK THAT TASK SPECIFICATIONS AND SUBPROGRAM SPECIFICATIONS CANNOT
--     BE DESIGNATED IN  USE  CLAUSES.


-- RM 3/15/1982


PROCEDURE  B84001A  IS

     PROCEDURE  PR(X,Y:INTEGER) ;

     TASK TYPE  TT  IS
          ENTRY  A ;
     END  TT ;

     TASK  T  IS
          ENTRY  B ;
     END  T ;

     TASK BODY  TT  IS
     BEGIN
          ACCEPT  A ;
     END  TT ;

     TASK BODY  T  IS
     BEGIN
          ACCEPT  B ;
     END  T ;

     FUNCTION   FN(X,Y:INTEGER) RETURN BOOLEAN  IS
     BEGIN
          RETURN TRUE ;
     END  FN ;

     PROCEDURE  PR(X,Y:INTEGER)  IS
     BEGIN
          NULL ;
     END  PR ;


     -------------------------------------------------------------------

     PROCEDURE  USER  IS
          USE  TT ;                             -- ERROR: NOT A PACKAGE.
          USE  T ;                              -- ERROR: NOT A PACKAGE.
          USE  PR ;                             -- ERROR: NOT A PACKAGE.
          USE  FN ;                             -- ERROR: NOT A PACKAGE.
          USE  PR , FN , T , TT ;               -- ERROR: NOT PACKAGES.
     BEGIN
          NULL ;
     END  USER ;

     -------------------------------------------------------------------


BEGIN

     -------------------------------------------------------------------

     DECLARE
          USE  TT ;                             -- ERROR: NOT A PACKAGE.
          USE  T ;                              -- ERROR: NOT A PACKAGE.
          USE  PR ;                             -- ERROR: NOT A PACKAGE.
          USE  FN ;                             -- ERROR: NOT A PACKAGE.
          USE  PR , FN , T , TT ;               -- ERROR: NOT PACKAGES.
     BEGIN
          NULL ;
     END ;

     -------------------------------------------------------------------


END  B84001A ;
