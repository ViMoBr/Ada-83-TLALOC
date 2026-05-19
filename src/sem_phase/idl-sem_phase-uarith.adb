------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

with TEXT_IO; use  TEXT_IO;
separate(	IDL.SEM_PHASE )

					------
package body				UARITH
is					------
    
  use UNIV_OPS, EXPRESO;
   

			-------
  function		IS_ZERO		( V :VECTOR )	return BOOLEAN
  is			-------
  begin
    return  V.D( 1 .. V.L ) = ( 1 .. V.L => 0 );

  end	IS_ZERO;
	-------


			-----
  function		U_VAL		( A :INTEGER )	return TREE
  is			-----
    A_SPREAD	: VECTOR;

  begin
    SPREAD( A, A_SPREAD );
    return  U_INT( A_SPREAD );

  end	U_VAL;
	-----


			-------
  function		U_VALUE		( TXT :STRING )	return TREE
  is			-------
  begin
    return  EVAL_NUM( TXT );

  end	U_VALUE;
	-------


			-----
  function		U_POS		( A :TREE )	return INTEGER
  is			-----
  begin
    if  A.PT = HI  and  A.NOTY = DN_NUM_VAL  then
      if  A.NSIZ = 0  then
        return  INTEGER( A.ABSS );
      elsif  A.NSIZ = 1  then
        return  INTEGER( -A.ABSS - 1 );
      end if;
    end if;
    PUT_LINE( "ERR U_POS" );
    raise PROGRAM_ERROR;

  end	U_POS;
	-----


			-------
  function		U_EQUAL		( LEFT, RIGHT :TREE )	return TREE
  is			-------
  begin
    if  LEFT = TREE_VOID  or  RIGHT = TREE_VOID  then
      return TREE_VOID;
    elsif  (LEFT.PT = HI  and then  LEFT.NOTY = DN_NUM_VAL)  or else  LEFT.TY = DN_NUM_VAL  then
      declare
        L_SPREAD, R_SPREAD	: VECTOR;
      begin
        SPREAD( LEFT, L_SPREAD );
        SPREAD( RIGHT, R_SPREAD );
        if  L_SPREAD.S = R_SPREAD.S  and then  V_EQUAL( L_SPREAD, R_SPREAD )  then
	return  U_VAL( 1 );
        else
	return  U_VAL( 0 );
        end if;
      end;
    else												--| VALEUR REELLE
      return  U_EQUAL( D( XD_NUMER, LEFT) * D( XD_DENOM, RIGHT ), D( XD_NUMER, RIGHT ) * D( XD_DENOM, LEFT ) );
    end if;

  end	U_EQUAL;
	-------


			-----------
  function		U_NOT_EQUAL	( LEFT, RIGHT :TREE )	return TREE
  is			-----------
  begin
    return  not U_EQUAL( LEFT, RIGHT );

  end	U_NOT_EQUAL;
	-----------


			---
  function		"<"		( LEFT, RIGHT : TREE )	return TREE
  is			---
  begin
    if  LEFT = TREE_VOID  or  RIGHT = TREE_VOID  then
      return  TREE_VOID;
	  
    elsif  ( (LEFT.PT = HI  and then  LEFT.NOTY = DN_NUM_VAL)  or else  LEFT.TY = DN_NUM_VAL )
       and then ( (RIGHT.PT = HI  and then  RIGHT.NOTY = DN_NUM_VAL)  or else  RIGHT.TY = DN_NUM_VAL )
    then
      declare
        L_SPREAD, R_SPREAD	: VECTOR;
      begin
        SPREAD( LEFT, L_SPREAD );
        SPREAD( RIGHT, R_SPREAD );
        if  L_SPREAD.S < 0  then
	if R_SPREAD.S > 0 or else V_LESS( R_SPREAD, L_SPREAD ) then
	  return  U_VAL( 1 );
	end if;
        else
	if  R_SPREAD.S > 0  and then  V_LESS( L_SPREAD, R_SPREAD )  then
	  return  U_VAL( 1 );
	end if;
        end if;
        return  U_VAL( 0 );
      end;

    else												--| VALEUR REELLE
      return  "<" (	D( XD_NUMER, LEFT )	* D( XD_DENOM, RIGHT ),
		D( XD_NUMER, RIGHT ) * D( XD_DENOM, LEFT )
	     );
    end if;

  end	"<";
	---


			----
  function		"<="		( LEFT, RIGHT :TREE )	return TREE
  is			----
  begin
    return  not( RIGHT < LEFT );

  end	"<=";
	----


			---
  function		">"		( LEFT, RIGHT :TREE )	return TREE
  is			---
  begin
    return  (RIGHT < LEFT);

  end	">";
	---

			----
  function		">="		( LEFT, RIGHT :TREE )	return TREE
  is			----
  begin
    return  not( LEFT < RIGHT );

  end	">=";
	----


			--------
  function		U_MEMBER		( VALUE, DISCRETE_RANGE :TREE )	return TREE
  is			--------
  begin
    if  VALUE = TREE_VOID  then
      return  TREE_VOID;
    end if;
      
    if  DISCRETE_RANGE.TY = DN_RANGE  then
      return  (VALUE >= EXPRESO.GET_STATIC_VALUE( D( AS_EXP1, DISCRETE_RANGE ) ) )
	and (VALUE <= GET_STATIC_VALUE( D(AS_EXP2, DISCRETE_RANGE	) ) );
         
    elsif  DISCRETE_RANGE.TY = DN_RANGE_ATTRIBUTE  then
      TEXT_IO.PUT_LINE( "!! $$$$ RANGE ATTR DISCR SUBT" );
      return  TREE_VOID;
         
    elsif  DISCRETE_RANGE.TY = DN_DISCRETE_SUBTYPE  then
      declare
        SUBTYPE_INDICATION	: constant TREE	:= D( AS_SUBTYPE_INDICATION, DISCRETE_RANGE );
        NAME		: constant TREE	:= D( AS_NAME, SUBTYPE_INDICATION );
        CONSTRAINT		: constant TREE	:= D( AS_CONSTRAINT, SUBTYPE_INDICATION	);
      begin
        if  CONSTRAINT.TY in CLASS_RANGE  then
	return  U_MEMBER( VALUE, CONSTRAINT );
        elsif  CONSTRAINT.TY in CLASS_REAL_CONSTRAINT  and then  D( AS_RANGE, CONSTRAINT ) /= TREE_VOID  then
	return  U_MEMBER( VALUE, D( AS_RANGE, CONSTRAINT ) );
        elsif  CONSTRAINT /= TREE_VOID  then
	PUT_LINE( "!! $$$$ U_MEMBER: INDEX/DSCRMT CONSTRAINT" );
	raise  PROGRAM_ERROR;
        end if;
	  
        if  D( SM_DEFN, NAME ) = TREE_VOID then
	return  TREE_VOID;
        end if;
			  -- (BETTER BE A DISCRETE SUBTYPE)
        return U_MEMBER( VALUE, D( SM_RANGE, D( SM_TYPE_SPEC, D( SM_DEFN, NAME ) ) ) );
      end;
    end if;
    return  TREE_VOID;

  end	U_MEMBER;
	--------


			----
  function		"<="		( LEFT, RIGHT :TREE )	return BOOLEAN
  is			----
  begin
    return (LEFT <= RIGHT) = U_VAL( 1 );

  end	"<=";
	----

			----
  function		">="		( LEFT, RIGHT :TREE )	return BOOLEAN
  is			----
  begin
    return  (LEFT >= RIGHT) = U_VAL( 1 );

  end	">=";
	----


			-------
  function		U_EQUAL		( LEFT, RIGHT :TREE )	return BOOLEAN
  is			-------
  begin
    return  U_EQUAL( LEFT, RIGHT ) = U_VAL ( 1 );

  end	U_EQUAL;
	-------


			--------
  function		U_MEMBER		( VALUE, DISCRETE_RANGE :TREE )	return BOOLEAN
  is			--------
  begin
    return  U_MEMBER( VALUE, DISCRETE_RANGE ) = U_VAL( 1 );

  end	U_MEMBER;
	--------


			-----
  function		"AND"		( LEFT, RIGHT :TREE )	return TREE
  is			-----
  begin
    if  LEFT = TREE_VOID  or  RIGHT = TREE_VOID  then
      return TREE_VOID;
    elsif  LEFT.ABSS > 0  and  RIGHT.ABSS > 0  then
      return  U_VAL( 1 );
    else
      return  U_VAL( 0 );
    end if;

end	"AND";
	-----


			----
  function		"OR"		( LEFT, RIGHT :TREE )	return TREE
  is			----
  begin
    if  LEFT = TREE_VOID  or  RIGHT = TREE_VOID  then
      return  TREE_VOID;
    elsif  LEFT.ABSS > 0  or  RIGHT.ABSS > 0  then
      return  U_VAL( 1 );
    else
      return  U_VAL( 0 );
    end if;

  end	"OR";
	----


			-----
  function		"XOR"		( LEFT, RIGHT :TREE )	return TREE
  is			-----
  begin
    if  LEFT = TREE_VOID  or  RIGHT = TREE_VOID  then
      return  TREE_VOID;
    elsif  LEFT.ABSS /= RIGHT.ABSS  then
      return  U_VAL( 1 );
    else
      return  U_VAL( 0 );
    end if;

  end	"XOR";
	-----



--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION "NOT"
function "NOT" ( RIGHT :TREE ) return TREE is
begin
  if RIGHT = TREE_VOID then
    return TREE_VOID;
  else
    return U_VAL( 1	- INTEGER( RIGHT.ABSS mod 2 )	);
  end if;
end "NOT";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|	FUNCTION "-"
function "-" ( RIGHT :TREE ) return TREE is
begin
  if RIGHT = TREE_VOID then
    return TREE_VOID;
  elsif (RIGHT.PT =	HI and then RIGHT.NOTY = DN_NUM_VAL) or	else RIGHT.TY = DN_NUM_VAL then
    declare
      R_SPREAD	: VECTOR;
    begin
      SPREAD( RIGHT, R_SPREAD	);
      R_SPREAD.S :=	- R_SPREAD.S;
      return U_INT(	R_SPREAD );
    end;
  else										--| REEL
    return U_REAL (	- D ( XD_NUMER, RIGHT ), D ( XD_DENOM, RIGHT ) );
  end if;
end "-";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|	FUNCTION "ABS"
function "ABS" ( RIGHT :TREE ) return TREE is
begin
  if RIGHT = TREE_VOID then
    return TREE_VOID;
	  
  elsif (RIGHT.PT =	HI and then RIGHT.NOTY = DN_NUM_VAL) or	else RIGHT.TY = DN_NUM_VAL then
    declare
      R_SPREAD	: VECTOR;
    begin
      SPREAD( RIGHT, R_SPREAD	);
      if R_SPREAD.S	> 0 then
        return RIGHT;
      else
        R_SPREAD.S := +1;
        return U_INT( R_SPREAD );
      end	if;
    end;
  else										--| DOIT ETRE UN REEL
    return U_REAL (	abs D ( XD_NUMER, RIGHT ), D ( XD_DENOM, RIGHT ) );
  end if;
end "ABS";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION "+"
function "+" ( LEFT, RIGHT :TREE ) return TREE is
begin
  if LEFT	= TREE_VOID or RIGHT = TREE_VOID then
    return TREE_VOID;
	
  elsif (LEFT.PT = HI and then LEFT.NOTY = DN_NUM_VAL) or else LEFT.TY = DN_NUM_VAL then
    declare
      L_SPREAD, R_SPREAD	: VECTOR;
    begin
      SPREAD ( LEFT, L_SPREAD	);
      SPREAD ( RIGHT, R_SPREAD );
	     
      if L_SPREAD.S	= R_SPREAD.S then
        V_ADD ( L_SPREAD, R_SPREAD );
        return U_INT ( R_SPREAD );
	       
      elsif V_EQUAL	( L_SPREAD, R_SPREAD ) then
        return U_VAL ( 0 );
	        
      elsif V_LESS ( L_SPREAD, R_SPREAD	) then
        V_SUB ( L_SPREAD, R_SPREAD );
        return U_INT ( R_SPREAD );
	        
      else
        V_SUB ( R_SPREAD, L_SPREAD );
        return U_INT ( L_SPREAD);
      end	if;
    end;
  else					--| REEL
    return U_REAL(
	     D ( XD_NUMER, LEFT ) * D	( XD_DENOM, RIGHT )	+ D ( XD_NUMER, RIGHT ) * D (	XD_DENOM,	LEFT ),
	     D ( XD_DENOM, LEFT ) * D	( XD_DENOM, RIGHT )
	     );
  end if;
end "+";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION "-"
function "-" ( LEFT, RIGHT :TREE ) return TREE is
begin
  if LEFT	= TREE_VOID or RIGHT = TREE_VOID then
    return TREE_VOID;
	  
  elsif (LEFT.PT = HI and then LEFT.NOTY = DN_NUM_VAL) or else LEFT.TY = DN_NUM_VAL then
    declare
      L_SPREAD, R_SPREAD	: VECTOR;
    begin
      SPREAD ( LEFT, L_SPREAD	);
      SPREAD ( RIGHT, R_SPREAD );
      R_SPREAD.S :=	- R_SPREAD.S;
			  -- REST	OF CODE SAME AS +
      if L_SPREAD.S	= R_SPREAD.S then
        V_ADD ( L_SPREAD, R_SPREAD );
        return U_INT ( R_SPREAD );
	        
      elsif V_EQUAL	( L_SPREAD, R_SPREAD ) then
        return U_VAL ( 0 );
	        
      elsif V_LESS ( L_SPREAD, R_SPREAD	) then
        V_SUB ( L_SPREAD, R_SPREAD );
        return U_INT ( R_SPREAD );
      else
        V_SUB ( R_SPREAD, L_SPREAD );
        return U_INT ( L_SPREAD );
      end	if;
    end;
  else --	MUST BE REAL_VAL
    return U_REAL(
	     D ( XD_NUMER, LEFT ) * D	( XD_DENOM, RIGHT )	- D ( XD_NUMER, RIGHT ) * D (	XD_DENOM,	LEFT ),
	     D ( XD_DENOM, LEFT ) * D	( XD_DENOM, RIGHT )
	     );
  end if;
end "-";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|		FUNCTION "*"
--|
function "*" ( LEFT, RIGHT :TREE ) return TREE is
  LEFT_IS_INT	: BOOLEAN	:= (LEFT.PT = HI and then LEFT.NOTY = DN_NUM_VAL)	or else LEFT.TY = DN_NUM_VAL;
  RIGHT_IS_INT	: BOOLEAN	:= (RIGHT.PT = HI and then RIGHT.NOTY =	DN_NUM_VAL) or else	RIGHT.TY = DN_NUM_VAL;
begin
  if LEFT	= TREE_VOID or RIGHT = TREE_VOID then
    return TREE_VOID;
	  
  elsif LEFT_IS_INT	and RIGHT_IS_INT then
    declare
      L_SPREAD, R_SPREAD	: VECTOR;
      TEMP		: VECTOR;
    begin
      SPREAD( LEFT,	L_SPREAD );
      SPREAD( RIGHT, R_SPREAD	);
      V_MUL( L_SPREAD, R_SPREAD, TEMP );
      TEMP.S := L_SPREAD.S * R_SPREAD.S;
      return U_INT(	TEMP );
    end;
  elsif RIGHT_IS_INT then
    return U_REAL( D( XD_NUMER, LEFT ) * RIGHT, D( XD_DENOM, LEFT ) );
  elsif LEFT_IS_INT	then
    return RIGHT * LEFT;
  else										--| REELS
    return U_REAL( D( XD_NUMER, LEFT ) * D( XD_NUMER, RIGHT	), D( XD_DENOM, LEFT ) * D( XD_DENOM, RIGHT ) );
  end if;
end "*";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|	FUNCTION "/"
--|
function "/" ( LEFT, RIGHT :TREE ) return TREE is
  LEFT_IS_INT	: BOOLEAN	:= (LEFT.PT = HI and then LEFT.NOTY = DN_NUM_VAL)	or else LEFT.TY = DN_NUM_VAL;
  RIGHT_IS_INT	: BOOLEAN	:= (RIGHT.PT = HI and then RIGHT.NOTY =	DN_NUM_VAL) or else	RIGHT.TY = DN_NUM_VAL;
begin
  if LEFT	= TREE_VOID or RIGHT = TREE_VOID then
    return TREE_VOID;
	  
  elsif LEFT_IS_INT	and RIGHT_IS_INT then
    declare
      L_SPREAD, R_SPREAD	: VECTOR;
      TEMP		: VECTOR;
    begin
      SPREAD( RIGHT, R_SPREAD	);
      if IS_ZERO( R_SPREAD ) then
        return TREE_VOID;
      end	if;
      SPREAD( LEFT,	L_SPREAD );
      V_DIV( R_SPREAD, L_SPREAD, TEMP );
      TEMP.S := L_SPREAD.S * R_SPREAD.S;
      return U_INT(	TEMP );
    end;
  elsif RIGHT_IS_INT then
    if RIGHT = U_VAL( 0) then
      return TREE_VOID;
    end if;
    return U_REAL( D( XD_NUMER, LEFT ),	D( XD_DENOM, LEFT )	* RIGHT );
  else												--| REELS
    if D(	XD_NUMER,	RIGHT ) =	U_VAL( 0 ) then
      return TREE_VOID;
    end if;
    return U_REAL( D( XD_NUMER, LEFT ) * D( XD_DENOM, RIGHT	), D( XD_DENOM, LEFT ) * D( XD_NUMER, RIGHT ) );
  end if;
end "/";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|	FUNCTION "MOD"
function "MOD" ( LEFT, RIGHT :TREE ) return TREE is
begin
  if LEFT	= TREE_VOID or RIGHT = TREE_VOID then
    return TREE_VOID;
	  
  else
    declare
      L_SPREAD, R_SPREAD	: VECTOR;
      TEMP		: VECTOR;
    begin
      SPREAD( LEFT,	L_SPREAD );
      SPREAD( RIGHT, R_SPREAD	);
	  
      if IS_ZERO( R_SPREAD ) then
        return TREE_VOID;								--| DIV ZERO
      end	if;
	  
      V_DIV( R_SPREAD, L_SPREAD, TEMP );
      if L_SPREAD.S	/= R_SPREAD.S and then not IS_ZERO( L_SPREAD ) then
        V_SUB( L_SPREAD, R_SPREAD );
        L_SPREAD.D(	1..R_SPREAD.L ) := R_SPREAD.D( 1..R_SPREAD.L );
      end	if;
      L_SPREAD.S :=	R_SPREAD.S;
      return U_INT(	L_SPREAD );
    end;
  end if;
end "MOD";
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--|	FUNCTION "REM"
function "REM" ( LEFT, RIGHT :TREE ) return TREE is
begin
  if LEFT	= TREE_VOID or RIGHT = TREE_VOID then
    return TREE_VOID;
	  
  else
    declare
      L_SPREAD, R_SPREAD	: VECTOR;
      TEMP		: VECTOR;
    begin
      SPREAD( LEFT,	L_SPREAD );
      SPREAD( RIGHT, R_SPREAD	);
	  
      if IS_ZERO( R_SPREAD ) then
        return TREE_VOID;								--| DIV ZERO
      end	if;
	  
      V_DIV( R_SPREAD, L_SPREAD, TEMP );						--| LE SIGNE EST CELUI DU L_SPREAD D'ORIGINE
      return U_INT(	L_SPREAD );
    end;
  end if;
end "REM";


			----
  function		"**"		( LEFT, RIGHT :TREE )	return TREE
  is
  begin
    if  LEFT = TREE_VOID  or  RIGHT = TREE_VOID  then
      return  TREE_VOID;

    elsif  (LEFT.PT = HI  and then  LEFT.NOTY = DN_NUM_VAL)  or else  LEFT.TY = DN_NUM_VAL  then
      declare
        L_SPREAD	: VECTOR;
        TEMP	: VECTOR;
        RESULT	: VECTOR;
        COUNT	: INTEGER		:= U_POS(	RIGHT );
      begin
        if  COUNT < 0  then
	return  TREE_VOID;										--| CONSTRAINT ERROR FOR - EXP
        end if;
        SPREAD( LEFT, L_SPREAD );
        SPREAD( 1, RESULT );
        while  COUNT > 0  loop
	V_MUL( L_SPREAD, RESULT, TEMP );
	RESULT   := TEMP;
	RESULT.S := RESULT.S * L_SPREAD.S;
	COUNT    := COUNT - 1;
        end loop;
        return U_INT( RESULT );
      end;
	  
    else
      if  U_POS( RIGHT ) >= 0  then
        return  U_REAL( D( XD_NUMER, LEFT ) ** RIGHT, D( XD_DENOM, LEFT ) ** RIGHT );
      else
        return  U_REAL( D( XD_DENOM, LEFT ) ** (- RIGHT), D( XD_NUMER, LEFT ) ** (-RIGHT) );
      end if;
    end if;

end	"**";
	----


	------
end	UARITH;
	------

--	1	2	3	4	5	6	7	8	9	0	1	2
------------------------------------------------------------------------------------------------------------------------

