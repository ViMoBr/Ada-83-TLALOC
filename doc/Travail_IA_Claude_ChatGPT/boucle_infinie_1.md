##backtrace et map
<pre>
#0  0x0000000000405137 in ?? ()
INTEGER_POW_L63 0x0000000000405011
var elab R 0x000000000040502F
 disp 0x0000000000000008
var elab B 0x0000000000405051
 disp 0x0000000000000010
var elab E 0x0000000000405071
 disp 0x0000000000000018
 spec 0x0000000000405290

#1  0x0000000000657a9a in ?? ()
WALK_L42 0x000000000064F9E3
....
var elab BLTN_OPERATOR_ID 0x00000000006561F9
 disp 0x00000000000000D0
 **zone appel**
var elab VALUE 0x0000000000658273
 disp 0x0000000000000008

#2  0x000000000065ac41 in ?? ()
var elab ITEM_NODE 0x000000000065A4C6
 disp 0x0000000000000028
 **zone appel**
MAKE_PREDEF_IDS_L171 0x000000000065AC82

#3  0x000000000065641f in ?? ()
var elab PARAM2 0x0000000000656141
 disp 0x00000000000000B8
var elab BLTN_OPERATOR_ID 0x00000000006561F9
 disp 0x00000000000000D0
 **zone appel**
var elab VALUE 0x0000000000658273
 disp 0x0000000000000008

#4  0x0000000000658abe in ?? ()
#5  0x0000000000654110 in ?? ()
#6  0x0000000000651369 in ?? ()
#7  0x000000000065ac41 in ?? ()
#8  0x00000000006595a8 in ?? ()
#9  0x00000000006520af in ?? ()
#10 0x000000000065ac41 in ?? ()
#11 0x00000000006595a8 in ?? ()
#12 0x00000000006520af in ?? ()
#13 0x0000000000659d2b in ?? ()
#14 0x000000000065ac41 in ?? ()
#15 0x000000000065993e in ?? ()
#16 0x000000000065f853 in ?? ()
#17 0x0000000000661ca9 in ?? ()
#18 0x0000000000d8abbb in ?? ()
#19 0x0000000000d8bbad in ?? ()
</pre>

##pile
<pre>
(gdb) x/16gx $rbp-64
0x7fffffc1dd78: 0x0000000000000000      0x00007fffffc1dc40
0x7fffffc1dd88: 0x00007fffffc1dc28      0x00007fffffc066e0
0x7fffffc1dd98: 0x0000000000000000      0x00007fffffc1dc28
0x7fffffc1dda8: 0x00007fffebec7ae5      0x00007fffffc04c68
0x7fffffc1ddb8: 0x00007fffebec7a01      0x0000000000000000
0x7fffffc1ddc8: 0x00007fff86009ebc      0x00007fffffc04c68
0x7fffffc1ddd8: 0x00007fffffc1da40      0x0000000000000004
0x7fffffc1dde8: 0x00007fffffc1ddb0      0x00007fffffc066e0
</pre>

## Zone Ada : FIX_PRE.WALK
<pre>
	  when DN_FUNCTION_CALL =>
	     declare
	        use UARITH;
	        use PRENAME;
	     
	        NAME	: constant TREE	:= D ( AS_NAME, NODE );
	        GENERAL_ASSOC_S	: constant TREE	:= D ( AS_GENERAL_ASSOC_S, NODE );
	        PARAM	: TREE	:= HEAD ( LIST ( GENERAL_ASSOC_S ) );
	        PARAM2	: TREE	:= TREE_VOID;
	        BLTN_OPERATOR_ID	: TREE	:= HEAD ( LIST ( D ( LX_SYMREP, NAME ) ) );
	     begin
				-- ONLY FOR UNARY "-", "*", "**" IN RANGES
	        WALK ( GENERAL_ASSOC_S, NODE, REGION );
	     
	        if not IS_EMPTY ( TAIL ( LIST ( GENERAL_ASSOC_S))) then
		 PARAM2 := HEAD ( TAIL ( LIST ( GENERAL_ASSOC_S ) ) );
	        end if;
	     
	        if (PARAM2 = TREE_VOID) xor ( OP_CLASS'VAL ( DI ( SM_OPERATOR, BLTN_OPERATOR_ID ) ) in CLASS_UNARY_OP ) then
		 BLTN_OPERATOR_ID := HEAD ( TAIL ( LIST ( D ( LX_SYMREP, NAME ) ) ) );
	        end if;
	     
	        D ( AS_NAME, NODE, MAKE_USED_OP (
			SM_DEFN	=> BLTN_OPERATOR_ID,
			LX_SYMREP => D ( LX_SYMREP, NAME), LX_SRCPOS => D ( LX_SRCPOS, NAME )
			)
		 );
	     
	        if PRINT_NAME ( D ( LX_SYMREP, NAME ) ) = """-""" then
		 if PARAM2 = TREE_VOID then
		    D ( SM_VALUE, NODE, -D( SM_VALUE, PARAM ) );
		 else
		    D ( SM_VALUE, NODE, D ( SM_VALUE, PARAM ) - D ( SM_VALUE, PARAM2 ) );
		 end if;
	        elsif PRINT_NAME ( D ( LX_SYMREP, NAME ) ) = """*""" then
		 D ( SM_VALUE, NODE, D ( SM_VALUE, PARAM ) * D ( SM_VALUE, PARAM2 ) );

-- ICI PROBABLE BOUCLE INFINIE
	        elsif PRINT_NAME ( D ( LX_SYMREP, NAME ) ) = """**""" then
		 D ( SM_VALUE, NODE, D ( SM_VALUE, PARAM ) ** D ( SM_VALUE, PARAM2 ) );
--
	        else
		 ABORT_RUN ( "FUNCTION NOT ALLOWED - " & PRINT_NAME ( D ( LX_SYMREP, NAME ) ) );
		 raise PROGRAM_ERROR;
	        end if;
	     
	        D ( SM_EXP_TYPE, NODE, GET_BASE_TYPE ( D ( SM_EXP_TYPE, PARAM ) ) );
	        D ( SM_NORMALIZED_PARAM_S, NODE, MAKE_EXP_S (
			LIST	=> LIST ( GENERAL_ASSOC_S ),
			LX_SRCPOS => D ( LX_SRCPOS, GENERAL_ASSOC_S)
			)
		 );


	     end;
         
	  when DN_NUMERIC_LITERAL =>
</pre>

## section de FIX_PRE.FINC interessée :
<pre>
VAR	ANON_427_24_disp, q
VAR	ANON_427_24__u,    q
VAR	ANON_427_24__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_427_24__dat
	Sa  4, ANON_427_24_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_427_24__u
	LVA 4, ANON_427_24_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
VAR	ANON_427_49_disp, q
VAR	ANON_427_49__u,    q
VAR	ANON_427_49__dat, STANDARD.IDL._TREE.size
	LVA 4, ANON_427_49__dat
	Sa  4, ANON_427_49_disp
	La  0, STANDARD.IDL._TREE.use__info
	Sa  4, ANON_427_49__u
	LVA 4, ANON_427_49_disp
					; doublet resultat record anonyme
	LVA 4,	PARAM2_disp
	LI  88
	CALL	STANDARD.IDL. ,D_L17
VAR	POWN_L136, q
VAR	POWX_L137, q
	Sq  4, POWN_L136
	Sq  4, POWX_L137
	LI	0					; lieu resultat sur pile
	Lq  4, POWN_L136
	Lq  4, POWX_L137
	CALL	STANDARD. ,INTEGER_POW_L63
	La  3,	-NODE_ofs
	LI  88
	CALL	STANDARD.IDL. ,D_L16
	BRA	L124
</pre>