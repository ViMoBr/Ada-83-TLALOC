-- B35004A.ADA

-- CHECK THAT THE PREFIX OF FIRST AND LAST CANNOT BE A RECORD, 
-- ACCESS, OR PRIVATE TYPE (INCLUDING A GENERIC FORMAL PRIVATE TYPE).

-- RJW 2/13/86

PROCEDURE B35004A IS
     
BEGIN
     DECLARE
          TYPE R IS RECORD
               I1, I2 : INTEGER;
          END RECORD;          
          
          REC : R;
     BEGIN
          IF (R'FIRST = REC.I1) THEN     -- ERROR: PREFIX 'R' 
                                         --        NOT VALID.
               NULL;
          ELSIF (R'LAST = REC.I2) THEN   -- ERROR: PREFIX 'R' 
                                         --        NOT VALID.
               NULL;
          END IF;
     END;

     DECLARE
          TYPE ARR IS ARRAY (1 .. 5) OF INTEGER;
          TYPE ACC IS ACCESS ARR;
     BEGIN
          IF (ACC'FIRST = 1) THEN        -- ERROR: PREFIX 'ACC'      
                                         --        NOT VALID.
               NULL;
          ELSIF (ACC'LAST = 5) THEN      -- ERROR: PREFIX 'ACC' 
                                         --        NOT VALID.
               NULL;
          END IF;
     END;     
     
     DECLARE
          PACKAGE PKG IS 
               TYPE ARR IS PRIVATE;
          PRIVATE
               TYPE ARR IS ARRAY (1 .. 5) OF INTEGER;
          END PKG;

     BEGIN
          IF (PKG.ARR'FIRST = 1) THEN    -- ERROR: PREFIX 'PKG.ARR' 
                                         --        NOT VALID.
               NULL;
          ELSIF (PKG.ARR'LAST) = 5 THEN  -- ERROR: PREFIX 'PKG.ARR' 
                                         --        NOT VALID.
               NULL;
          END IF;
     END;

     DECLARE 
          TYPE ARR IS ARRAY (1 .. 5) OF INTEGER;
          
          GENERIC
               TYPE ARR IS PRIVATE;
          PROCEDURE PROC;
  
          PROCEDURE PROC IS
          BEGIN                            
               IF ARR'FIRST = 1 THEN     -- ERROR: PREFIX 'ARR' 
                                         --        NOT VALID.
                    NULL;
               ELSIF ARR'LAST = 5 THEN   -- ERROR: PREFIX 'ARR' 
                                         --        NOT VALID.
                    NULL;
               END IF;
          END PROC;

     BEGIN
          NULL;
     END;
          
END B35004A;
