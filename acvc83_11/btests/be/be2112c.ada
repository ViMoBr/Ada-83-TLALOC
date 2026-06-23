-- BE2112C.ADA

-- CHECK THAT THE INSTANTIATION OF DIRECT_IO IS REQUIRED FOR
-- THE EMPLOYMENT OF THE FOLLOWING SUBPROGRAMS:
--
--   CREATE            CLOSE             OPEN
--   RESET             MODE              NAME
--   FORM              IS_OPEN           END_OF_FILE
--   SET_INDEX         INDEX             SIZE
--   DELETE.

-- ABW  8/13/82

WITH DIRECT_IO ;

PROCEDURE BE2112C IS

     PACKAGE PKG IS
          TYPE FILE_TYPE IS LIMITED PRIVATE ;
     PRIVATE
          TYPE FILE_TYPE IS NEW INTEGER ;
     END PKG ;
     USE PKG ;
     FILE : FILE_TYPE ;
     TYPE FILE_MODE IS (IN_FILE,OUT_FILE,INOUT_FILE) ;
     TYPE COUNT IS RANGE -127..127 ;
     X_COUNT : COUNT := 8 ;
     SUBTYPE POSITIVE_COUNT IS COUNT RANGE 1..127 ;
     P_COUNT : POSITIVE_COUNT := 4 ;

BEGIN

     DIRECT_IO.CREATE (FILE, OUT_FILE, "X2112C");  -- ERROR: CREATE
     DIRECT_IO.CLOSE (FILE) ;                      -- ERROR: CLOSE
     DIRECT_IO.OPEN (FILE) ;                       -- ERROR: OPEN
     DIRECT_IO.RESET (FILE) ;                      -- ERROR: RESET
     DIRECT_IO.SET_INDEX (FILE,P_COUNT) ;          -- ERROR: SET_INDEX

     DECLARE

          AA : FILE_MODE :=
                  DIRECT_IO.MODE (FILE) ;          -- ERROR: MODE
          BB : CONSTANT STRING :=
                  DIRECT_IO.NAME (FILE) ;          -- ERROR: NAME
          CC : CONSTANT STRING :=
                  DIRECT_IO.FORM (FILE) ;          -- ERROR: FORM
          DD : BOOLEAN :=
                  DIRECT_IO.IS_OPEN (FILE) ;       -- ERROR: IS_OPEN
          EE : BOOLEAN :=
                  DIRECT_IO.END_OF_FILE (FILE) ;   -- ERROR: END_OF_FILE
          FF : POSITIVE_COUNT :=
                  DIRECT_IO.INDEX (FILE) ;         -- ERROR: INDEX
          GG : COUNT :=
                  DIRECT_IO.SIZE (FILE) ;          -- ERROR: SIZE

     BEGIN

          DIRECT_IO.DELETE (FILE) ;                -- ERROR: DELETE

     END ;

END BE2112C ;
