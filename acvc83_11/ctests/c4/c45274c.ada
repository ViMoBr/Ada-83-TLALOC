-- C45274C.ADA


-- CHECK THAT THE MEMBERSHIP OPERATOR  IN   ( NOT IN )
--     YIELDS  TRUE  (RESP.  FALSE ) IF THE DISCRIMINANTS OF THE LEFT
--     VALUE EQUAL THE DISCRIMINANTS OF THE SUBTYPE INDICATION.
--
--
--   * RECORD TYPES WITH DISCRIMINANTS;
--   * PRIVATE TYPES WITH DISCRIMINANTS;
--   * LIMITED PRIVATE TYPES WITH DISCRIMINANTS.


-- RM  3/01/82


WITH REPORT;
USE REPORT;
PROCEDURE C45274C IS


BEGIN

     TEST ( "C45274C" , "CHECK THAT THE MEMBERSHIP OPERATOR  IN " &
                        "  ( NOT IN )  YIELDS  TRUE   (RESP.  FALSE )" &
                        " IF THE DISCRIMINANTS OF THE LEFT VALUE" &
                        " EQUAL THE DISCRIMINANTS OF THE SUBTYPE" &
                        " INDICATION" );


     -------------------------------------------------------------------
     -----------------  RECORD TYPES WITH DISCRIMINANTS  ---------------

     DECLARE

          TYPE  REC ( DISCR : BOOLEAN := FALSE ) IS
               RECORD
                    A , B : INTEGER ;
               END RECORD ;

          SUBTYPE  RECTRUE  IS REC(TRUE) ;

          X : REC  :=  ( TRUE , 19 , 91 );

     BEGIN

          IF  X  IN  RECTRUE  THEN
               NULL;
          ELSE 
               FAILED( "WRONG VALUE: 'IN', 1" );
          END IF;

          IF  X  NOT IN  RECTRUE  THEN
               FAILED( "WRONG VALUE: 'NOT IN', 1" );
          ELSE 
               NULL;
          END IF;

     EXCEPTION

          WHEN  OTHERS =>
               FAILED( "1 -  'IN'  ( 'NOT IN' )  RAISED AN EXCEPTION");

     END;


     -------------------------------------------------------------------
     -----------------  PRIVATE TYPES WITH DISCRIMINANTS  --------------

     DECLARE

          PACKAGE  P  IS
               TYPE  PRIV ( DISCR : BOOLEAN ) IS PRIVATE;
          PRIVATE
               TYPE  PRIV ( DISCR : BOOLEAN ) IS
                    RECORD
                         A , B : INTEGER ;
                    END RECORD ;
          END  P ;

          USE  P ;

          SUBTYPE  PRIVTRUE  IS  PRIV( IDENT_BOOL(TRUE) );

          X : PRIV(TRUE) ;

          PACKAGE BODY  P  IS
          BEGIN
               X := ( TRUE , 19 , 91 );
          END  P ;

     BEGIN

          IF  X  IN  PRIVTRUE  THEN
               NULL;
          ELSE 
               FAILED( "WRONG VALUE: 'IN', 2" );
          END IF;

          IF  X  NOT IN  PRIVTRUE  THEN
               FAILED( "WRONG VALUE: 'NOT IN', 2" );
          ELSE 
               NULL;
          END IF;

     EXCEPTION

          WHEN  OTHERS =>
               FAILED( "2 -  'IN'  ( 'NOT IN' )  RAISED AN EXCEPTION");

     END;

     -------------------------------------------------------------------
     ---------  LIMITED PRIVATE TYPES WITH DISCRIMINANTS  --------------

     DECLARE

          PACKAGE  P  IS
               TYPE  LP ( DISCR : BOOLEAN := FALSE ) IS LIMITED PRIVATE;
          PRIVATE
               TYPE  LP ( DISCR : BOOLEAN := FALSE ) IS
                    RECORD
                         A , B : INTEGER ;
                    END RECORD ;
          END  P ;

          USE  P ;

          SUBTYPE  LPFALSE  IS  LP(FALSE) ;

          X : LP(TRUE) ;

          PACKAGE BODY  P  IS
          BEGIN
               X := ( IDENT_BOOL(TRUE) , 19 , 91 );
          END  P ;

     BEGIN

          IF  X  IN  LPFALSE  THEN
               FAILED( "WRONG VALUE: 'IN', 3" );
          ELSE 
               NULL;
          END IF;

          IF  X  NOT IN  LPFALSE  THEN
               NULL;
          ELSE 
               FAILED( "WRONG VALUE: 'NOT IN', 3" );
          END IF;

     EXCEPTION

          WHEN  OTHERS =>
               FAILED( "3 -  'IN'  ( 'NOT IN' )  RAISED AN EXCEPTION");

     END;


     -------------------------------------------------------------------


     RESULT;


END  C45274C ;
