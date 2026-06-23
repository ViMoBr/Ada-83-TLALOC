-- B83C01A.ADA


-- CHECK THAT ALL COMPONENT NAMES IN A <COMPONENT_LIST> OF A
--    RECORD DEFINITION ARE DISTINCT.
--    (THIS TEST CONCERNS BOTH NON-VARIANT RECORDS AND VARIANT RECORDS.)


--    RM  6/11/80
--    RM  9/10/80
--    JRK 11/10/80
--    ABW 6/17/82
--    VKG 1/5/83

PROCEDURE  B83C01A  IS

     TYPE  T1  IS
          RECORD
               B : INTEGER ;
               C : BOOLEAN ;
               B : INTEGER ; -- ERROR: NAME DUPLICATION  (SAME TYPE)
               C : INTEGER ; -- ERROR: NAME DUPLICATION  (DIFF. TYPES)
               D , E ,
               C ,           -- ERROR: NAME DUPLICATION  (3D OCCURRENCE)
               F : CHARACTER ;
          END RECORD ;

     TYPE  T1B  IS
          RECORD
               B : INTEGER ;
               C : BOOLEAN ;
               D , E ,
               F : CHARACTER ;
          END RECORD ;       -- CORRECT

     SUBTYPE INT5 IS INTEGER RANGE 1..5;
     SUBTYPE INT1 IS INTEGER RANGE 1..1;

     TYPE  T4 (DISCR : INT5 ; DIS : INTEGER)  IS
          RECORD
               COMMON_COMPONENT : INTEGER ;
               CASE  DISCR  IS

                    WHEN  1  =>

                         A : INTEGER ;
                         B : INTEGER ;
                         C : INTEGER ;
                         D : INTEGER ;
                         A : BOOLEAN ;  -- ERROR: DUPLICATION INSIDE A
                                        -- VARIANT.
                         DISCR : BOOLEAN ;  -- ERROR: REUSING THE NAME
                                        -- OF A DISCRIMINANT COMPONENT
                                        -- (DIFFERENT TYPE).
                         COMMON_COMPONENT : BOOLEAN ; -- ERROR: REUSING
                                        -- THE NAME OF A COMMON
                                        -- COMPONENT (DIFFERENT TYPE).

                    WHEN  3  =>

                         E : INTEGER ;
                         D : BOOLEAN ;  -- ERROR: DUPLICATION BETWEEN
                                        -- COMPONENTS IN DISTINCT
                                        -- VARIANTS (DIFF. TYPES).
                         DIS : INTEGER ;   -- ERROR: REUSING THE NAME
                                        -- OF A DISCRIMINANT COMPONENT
                                        -- (SAME TYPE).
                         COMMON_COMPONENT : INTEGER ; -- ERROR: REUSING
                                        -- THE NAME OF A COMMON
                                        -- COMPONENT (SAME TYPE).

                    WHEN  OTHERS  =>

                         A : INT1 ; -- ERROR: DUPLICATION
                                        -- BETWEEN COMPONENTS IN
                                        -- DISTINCT VARIANTS (SAME
                                        -- TYPE) (DIFFERENT SUBTYPES)
                                        -- ( 1 <-> OTHERS )
                         B : INTEGER ;  -- ERROR: DUPLICATION BETWEEN
                                        -- COMPONENTS IN DISTINCT
                                        -- VARIANTS (SAME TYPE, SUBTYPE)
                                        -- ( 1 <-> OTHERS )
                         E : INTEGER ;  -- ERROR: DUPLICATION BETWEEN
                                        -- COMPONENTS IN DISTINCT
                                        -- VARIANTS (SAME TYPE, SUBTYPE)
                                        -- ( 2 <-> OTHERS )
                         A : BOOLEAN ;  -- ERROR: DUPLIC. (INTRA+INTER)

               END CASE ;

          END RECORD ;


     TYPE T5 (A : INTEGER; B : BOOLEAN;
              A : INTEGER;   -- ERROR: NAME DUPLICATION (SAME TYPE)
              B : INTEGER    -- ERROR: NAME DUPLICATION (DIFF. TYPES)
             ) IS
          RECORD
               NULL;
          END RECORD;


BEGIN

     NULL ;

END B83C01A ;
