-- B35506A.ADA

-- OBJECTIVE:
--     CHECK THAT THE ARGUMENT TO  T'SUCC ,  T'PRED ,  T'POS , AND
--     T'IMAGE MUST HAVE THE BASE TYPE OF  T .

-- HISTORY:
--     RM  03/13/81  CREATED ORIGINAL TEST.
--     BCB 08/01/88  MODIFIED HEADER FORMAT AND ADDED CHECKS FOR 'IMAGE.


PROCEDURE  B35506A  IS
BEGIN

     DECLARE

          TYPE  ENUM   IS  ( AA , BB , CC , DD , EE , FF , GG ) ;

          TYPE  NEW_I  IS  NEW INTEGER   ;
          TYPE  NEW_C  IS  NEW CHARACTER ;
          TYPE  NEW_E  IS  NEW ENUM      ;

          IVAR :               INTEGER   :=  7  ;
          CVAR :               CHARACTER := 'A' ;
          EVAR :               ENUM      :=  AA ;

          ICON :      CONSTANT INTEGER   :=  7  ;
          CCON :      CONSTANT CHARACTER := 'A' ;
          ECON :      CONSTANT ENUM      :=  AA ;

          NEW_IVAR :           NEW_I     :=  7  ;
          NEW_CVAR :           NEW_C     := 'A' ;
          NEW_EVAR :           NEW_E     :=  AA ;

          NEW_ICON :  CONSTANT NEW_I     :=  7  ;
          NEW_CCON :  CONSTANT NEW_C     := 'A' ;
          NEW_ECON :  CONSTANT NEW_E     :=  AA ;

     BEGIN


          IF   NEW_I'SUCC(    IVAR) =  NEW_I'SUCC(    IVAR)-- ERROR:
          THEN  NULL ;
          END IF;

          IF CHARACTER'SUCC(NEW_CVAR)= CHARACTER'SUCC(NEW_CVAR)-- ERROR:
          THEN  NULL ;
          END IF;

          IF   NEW_E'SUCC(    ECON) =  NEW_E'SUCC(    ECON)-- ERROR:
          THEN  NULL ;
          END IF;


          IF   NEW_I'PRED(    ICON) =  NEW_I'PRED(    ICON)-- ERROR:
          THEN  NULL ;
          END IF;

          IF   NEW_C'PRED(    CVAR) =  NEW_C'PRED(    CVAR)-- ERROR:
          THEN  NULL ;
          END IF;

          IF   ENUM 'PRED(NEW_EVAR) =  ENUM 'PRED(NEW_EVAR)-- ERROR:
          THEN  NULL ;
          END IF;

          IF INTEGER'POS (NEW_IVAR) =INTEGER'POS (NEW_IVAR)-- ERROR:
          THEN  NULL ;
          END IF;

          IF   NEW_C'POS (    CCON) =  NEW_C'POS (    CCON)-- ERROR:
          THEN  NULL ;
          END IF;

          IF   NEW_E'POS (    EVAR) =  NEW_E'POS (    EVAR)-- ERROR:
          THEN  NULL ;
          END IF;

          IF NEW_I'IMAGE (ICON) = NEW_I'IMAGE (ICON) -- ERROR:
               THEN NULL;
          END IF;

          IF CHARACTER'IMAGE(NEW_CVAR) = CHARACTER'IMAGE(NEW_CVAR)
                                                     -- ERROR:
               THEN NULL;
          END IF;

          IF NEW_E'IMAGE(EVAR) = NEW_E'IMAGE(EVAR)  -- ERROR:
               THEN NULL;
          END IF;

     END ;


END B35506A ;
