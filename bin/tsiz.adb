PROCEDURE TSIZ IS

  type U8		is range 0 .. 255;						-- defaut non signe	: 8 attendu
  type S8		is range -128 .. 127;					-- defaut signe	: 8 attendu
  type S16	is range -1000 .. 1000;					-- defaut signe	: 16 attendu
  type U16C	is range 0 .. 255;		for U16C'SIZE use 16;		-- clause ELARGIT un non signe : 16 attendu
  type S16C	is range -100 .. 100;	for S16C'SIZE use 16;		-- clause ELARGIT un signe : 16 attendu
  type U8C	is range 0 .. 255;		for U8C'SIZE use 8;			-- clause = defaut : 8 attendu

  subtype H	is U8 range 0 .. 15;					-- sous-type : suit sa base (8)

  type FEU	is ( VERT, ORANGE, ROUGE );					-- enumere par defaut

  type VEC	is array ( 1 .. 5 ) of U16C;					-- propagation : COMP_SIZ 16 attendu (pas 8 !)

  A	: U8	:= 255;
  B	: S8	:= -1;
  C	: S16	:= 0;
  D	: U16C	:= 255;
  E	: S16C	:= -100;
  F	: U8C;
  G	: H	:= 12;
  FU	: FEU	:= ROUGE;
  V	: VEC;

BEGIN
  C	:= S16( B );		-- Lb SIGNE de B : -1 doit rester -1
  C	:= C + S16( G );		-- ULb de G, Lw signe de C
  F	:= U8C( A );		-- ULb de A : 255 doit rester 255
  D	:= D - 1;			-- ULw de D : conteneur 16 PAR CLAUSE
  E	:= E + 1;			-- Lw signe de E malgre le conteneur elargi
  V(3)	:= D;			-- store indexe : stride 16 bits
  FU	:= ORANGE;		-- enumere

END	TSIZ;
