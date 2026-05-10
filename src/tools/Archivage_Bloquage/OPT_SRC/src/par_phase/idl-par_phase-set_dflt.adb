------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT	MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

separate(	IDL.PAR_PHASE )
			--------
procedure			SET_DFLT		( NODE : TREE )						-- REMPLISSAGE INITIAL	PAR DEFAUT DES NOEUDS
is			--------

begin

  case NODE.TY is
  when DN_VARIABLE_ID =>
    D ( SM_INIT_EXP,    NODE,	TREE_VOID	);
    DB( SM_RENAMES_OBJ, NODE,	FALSE );
    D ( SM_ADDRESS,	    NODE,	TREE_VOID	);
    DB( SM_IS_SHARED,   NODE,	FALSE );

  when DN_CONSTANT_ID =>
    D ( SM_INIT_EXP,    NODE,	TREE_VOID	);
    DB( SM_RENAMES_OBJ, NODE,	FALSE );
    D ( SM_ADDRESS,	    NODE,	TREE_VOID	);
    D ( SM_FIRST,	    NODE,	NODE );

  when DN_COMPONENT_ID =>
    D ( SM_INIT_EXP,    NODE,	TREE_VOID	);
    D ( SM_COMP_REP,    NODE,	TREE_VOID	);

  when DN_DISCRIMINANT_ID =>
    D ( SM_INIT_EXP,    NODE,	TREE_VOID	);
    D ( SM_COMP_REP,    NODE,	TREE_VOID	);
    D ( SM_FIRST,	    NODE,	NODE );

  when CLASS_PARAM_NAME =>
    D ( SM_INIT_EXP,    NODE,	TREE_VOID	);
    D ( SM_FIRST,	    NODE,	NODE );

  when DN_TYPE_ID =>
    D ( SM_FIRST,	    NODE,	NODE );

  when DN_PROCEDURE_ID | DN_FUNCTION_ID	=>
    D ( SM_FIRST,		NODE,	NODE );
    D ( SM_ADDRESS,		NODE,	TREE_VOID	);
    D ( XD_STUB,		NODE,	TREE_VOID	);
    D ( XD_BODY,		NODE,	TREE_VOID	);
    DB( SM_IS_INLINE,	NODE,	FALSE );
    D ( SM_INTERFACE,	NODE,	TREE_VOID	);
    DB( CD_COMPILED,	NODE,	FALSE );
    DI( CD_LABEL,		NODE,	0 );

  when DN_OPERATOR_ID =>
    D ( SM_FIRST,		NODE,	NODE );
    D ( SM_ADDRESS,		NODE,	TREE_VOID	);
    D ( XD_STUB,		NODE,	TREE_VOID	);
    D ( XD_BODY,		NODE,	TREE_VOID	);
    DB(SM_IS_INLINE,	NODE,	FALSE );
    D ( SM_INTERFACE,	NODE,	TREE_VOID	);
    D ( XD_NOT_EQUAL,	NODE,	TREE_VOID	);
    DB( CD_COMPILED,	NODE,	FALSE );
    DI( CD_LABEL,		NODE,	0 );

  when DN_PACKAGE_ID =>
    D ( SM_FIRST,		NODE,	NODE );
    D ( SM_ADDRESS,		NODE,	TREE_VOID	);
    D ( XD_STUB,		NODE,	TREE_VOID	);
    D ( XD_BODY,		NODE,	TREE_VOID	);

  when DN_GENERIC_ID =>
    D ( SM_FIRST,		NODE,	NODE );
    D ( XD_STUB,		NODE,	TREE_VOID	);
    D ( XD_BODY,		NODE,	TREE_VOID	);
    D ( SM_BODY,		NODE,	TREE_VOID	);
    DB( SM_IS_INLINE,	NODE,	FALSE );

  when DN_ENTRY_ID =>
    D ( SM_ADDRESS,		NODE,	TREE_VOID	);

  when DN_EXCEPTION_ID =>
    D ( SM_RENAMES_EXC,	NODE,	TREE_VOID	);

  when DN_PACKAGE_SPEC =>
    DB ( XD_BODY_IS_REQUIRED,	NODE, FALSE );

  when DN_DERIVED_DEF =>
    LIST ( NODE, (TREE_NIL,TREE_NIL) );

  when DN_EXIT =>
    D ( SM_STM,		NODE,	TREE_VOID	);

  when CLASS_USED_OBJECT =>
    D ( SM_VALUE,		NODE,	TREE_VOID	);

  when DN_ATTRIBUTE	| DN_SELECTED =>
    D ( SM_VALUE,		NODE,	TREE_VOID	);

  when DN_FUNCTION_CALL =>
    D ( SM_VALUE,		NODE,	TREE_VOID	);
    DB( LX_PREFIX,		NODE,	TRUE );

  when CLASS_EXP_VAL =>
    D ( SM_VALUE,		NODE,	TREE_VOID	);

  when DN_COMPILATION_UNIT =>
    D ( XD_PARENT,		NODE,	TREE_VOID	);
    DI( XD_NBR_PAGES,	NODE,	0	);

  when others =>
    null;
  end case;
      
end	SET_DFLT;
	--------

------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2

