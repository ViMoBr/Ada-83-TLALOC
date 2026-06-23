-- C83F03D1.ADA


-- SEPARATELY COMPILED PACKAGE BODY FOR USE WITH  C83F03D0M


--    RM    08 SEPTEMBER 1980
--    JRK   14 NOVEMBER  1980



SEPARATE (C83F03D0M)
PACKAGE BODY  C83F03D1  IS

     Y4 : INTEGER := 200 ;

     TYPE  T4  IS  ( G , H , I ) ;

     PROCEDURE  BUMP  IS
     BEGIN
          FLOW_INDEX := FLOW_INDEX + 1 ;
     END BUMP ;

     PACKAGE BODY  P  IS
     BEGIN

          GOTO  X1 ;

          BUMP ;
          BUMP ;

          <<LABEL_IN_MAIN>>   BUMP ;  GOTO  T3 ;
          BUMP ;
          <<T1>>   BUMP ;  GOTO  Z ;
          BUMP ;
          <<Y1>>   BUMP ;  GOTO  LABEL_IN_MAIN ;
          BUMP ;
          <<X1>>   BUMP ;  GOTO  T1 ;
          BUMP ;
          <<Z>>    BUMP ;  GOTO  Y1 ;
          BUMP ;
          <<T3>>   BUMP ;  GOTO  T4 ;
          BUMP ;
          <<LABEL_IN_OUTER>>   BUMP ;  GOTO  ENDING ;
          BUMP ;
          <<Y3>>   BUMP ;  GOTO  Y4 ;
          BUMP ;
          <<Y4>>   BUMP ;  GOTO  LABEL_IN_OUTER ;
          BUMP ;
          <<T4>>   BUMP ;  GOTO  Y3 ;
          BUMP ;

          << ENDING >>  NULL;

     END P ;

BEGIN

     << LABEL_IN_OUTER >>  NULL ;

END C83F03D1 ;
