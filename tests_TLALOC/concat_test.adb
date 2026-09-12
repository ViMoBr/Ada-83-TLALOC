with TEXT_IO; use TEXT_IO;

procedure CONCAT_TEST
is

   K : CHARACTER := CHARACTER'VAL( 0 );

   package INT_IO is new INTEGER_IO( INTEGER ); use INT_IO;

   subtype SHORT is INTEGER range 0 .. 9999;

   -----------------------------------------------------------------------
   --  Utilitaire : affiche un STRING entre crochets puis sa longueur
   -----------------------------------------------------------------------
   procedure SHOW( LABEL : STRING;  S : STRING )
   is
   begin
      PUT( LABEL );
      PUT( '[' );
      PUT( S );
      PUT( ']' );
      PUT( "  len=" );
      PUT( S'LENGTH, WIDTH => 0 );
      NEW_LINE;
   end SHOW;

   -----------------------------------------------------------------------
   --  1.  Agrégat qualifié dynamique  STRING'(1..N => '0')
   -----------------------------------------------------------------------
   function ZEROS( N : NATURAL ) return STRING
   is
   begin
      return STRING'(1 .. N => '0');
   end ZEROS;

   -----------------------------------------------------------------------
   --  2.  Concaténation  &
   -----------------------------------------------------------------------
   function REPEAT_CHAR( C : CHARACTER;  N : NATURAL ) return STRING
   is
   begin
      return STRING'(1 .. N => C);
   end REPEAT_CHAR;

   -----------------------------------------------------------------------
   --  3.  La fonction cible : TO_QUAD_DIGITS
   --      Formatage sur 4 chiffres avec zéros en tête
   --      (IMAGE sans signe = IMAG'FIRST+1 .. IMAG'LAST)
   -----------------------------------------------------------------------

   function TO_QUAD_DIGITS( S : SHORT ) return STRING
   is
      IMAG  : constant STRING  := SHORT'IMAGE( S );
      COMPL : NATURAL          := 4 - (IMAG'LENGTH - 1);
   begin
      return STRING'(1 .. COMPL => '0') & IMAG( IMAG'FIRST+1 .. IMAG'LAST );
   end TO_QUAD_DIGITS;

begin

   --  === 1. Agrégat qualifié dynamique ===
   PUT_LINE( "=== 1. Zeros ===" );
   SHOW( "zeros(0)=", ZEROS(0) );           --  []        len=0
   SHOW( "zeros(1)=", ZEROS(1) );           --  [0]       len=1
   SHOW( "zeros(4)=", ZEROS(4) );           --  [0000]    len=4

   --  === 2. Concatenation de base ===
   PUT_LINE( "=== 2. Concat ===" );
   SHOW( "ab&cd=",   "ab" & "cd"  );        --  [abcd]    len=4
   SHOW( "ab&[]=",   "ab" & ""    );        --  [ab]      len=2
   SHOW( "[]&cd=",   ""   & "cd"  );        --  [cd]      len=2
   SHOW( "a&b&c=",   "a"  & "b" & "c" );   --  [abc]     len=3

   --  === 3. Concat agrégat + slice ===
   PUT_LINE( "=== 3. Zeros & slice ===" );
   SHOW( "zeros(3)&XY=", ZEROS(3) & "XY" );  --  [000XY]   len=5

   --  === 4. TO_QUAD_DIGITS ===
   PUT_LINE( "=== 4. TO_QUAD_DIGITS ===" );
   SHOW( "    0 -> ", TO_QUAD_DIGITS(    0 ) );   --  [0000]
   SHOW( "    7 -> ", TO_QUAD_DIGITS(    7 ) );   --  [0007]
   SHOW( "   42 -> ", TO_QUAD_DIGITS(   42 ) );   --  [0042]
   SHOW( "  999 -> ", TO_QUAD_DIGITS(  999 ) );   --  [0999]
   SHOW( " 1000 -> ", TO_QUAD_DIGITS( 1000 ) );   --  [1000]
   SHOW( " 9999 -> ", TO_QUAD_DIGITS( 9999 ) );   --  [9999]

   --  === 5. Concat avec REPEAT_CHAR ===
   PUT_LINE( "=== 5. Repeat_char ===" );
   SHOW( "5*'X'=", REPEAT_CHAR('X', 5) );   --  [XXXXX]  len=5
   SHOW( "0*'Y'=", REPEAT_CHAR('Y', 0) );   --  []       len=0

   --  === 6. Concat de résultats de fonctions ===
   PUT_LINE( "=== 6. Fonctions & ===" );
   SHOW( "z(2)&z(3)=", ZEROS(2) & ZEROS(3) );   --  [00000]  len=5
   SHOW( "q(5)&q(12)=", TO_QUAD_DIGITS(5) & TO_QUAD_DIGITS(12) );  --  [00050012]  len=8

end CONCAT_TEST;
