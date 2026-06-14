#!/bin/bash
./comp_predef_units.sh
#./a83.sh ./ ./_standrd.ads W
#./a83.sh ./ ./_standrd.adb W
#./a83.sh ./ ./system.ads W
#./a83.sh ./ ./calendar.ads w
#./a83.sh ./ ./unchecked_deallocation.ads w
#./a83.sh ./ ./unchecked_conversion.ads w
#./a83.sh ./ ./io_exceptions.ads W
#./a83.sh ./ ./machine_code.ads W
#./a83.sh ./ ./text_io.ads W
#./a83.sh ./ ./text_io.adb W
#./a83.sh ./ ./sequential_io.ads W
#./a83.sh ./ ./sequential_io.adb W
#./a83.sh ./ ./direct_io.ads W
#./a83.sh ./ ./direct_io.adb W
#--------------------------------------------------
#	IDL
#--------------------------------------------------
./a83.sh ./ ./idl_tools/diana_node_attr_class_names.ads W
./a83.sh ./ ../src/ada_comp/idl.ads W
./a83.sh ./ ../src/ada_comp/idl.adb W

./a83.sh ./ ../src/communs/idl-page_man.adb w
./a83.sh ./ ../src/communs/idl-idl_tbl.adb w
./a83.sh ./ ../src/communs/idl-idl_man.adb w
#--------------------------------------------------
#	PAR_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/par_phase/grmr_tbl.ads W
./a83.sh ./ ../src/par_phase/grmr_ops.ads W
./a83.sh ./ ../src/par_phase/grmr_ops.adb W
./a83.sh ./ ../src/par_phase/lex.ads W
./a83.sh ./ ../src/par_phase/lex.adb W
./a83.sh ./ ../src/par_phase/idl-par_phase.adb W
./a83.sh ./ ../src/par_phase/idl-par_phase-set_dflt.adb W
#--------------------------------------------------
#	LIB_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-lib_phase.adb w
#--------------------------------------------------
#	SEM_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/sem_phase/idl-sem_phase.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-aggreso.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-att_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-chk_stat.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-def_util.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-def_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-derived.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-eval_num.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-exp_type.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-expreso.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-fix_pre.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-fix_with.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-gen_subs.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-hom_unit.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-instant.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-make_nod.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-newsnam.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-nod_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-pra_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-pre_fcns.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-red_subp.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-rep_clau.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-req_util.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-sem_glob.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-set_util.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-stm_walk.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-uarith.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-univ_ops.adb w
./a83.sh ./ ../src/sem_phase/idl-sem_phase-vis_util.adb w
#--------------------------------------------------
#	ERR_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-err_phase.adb w
#--------------------------------------------------
#	WRITE_LIB
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-write_lib.adb w
#--------------------------------------------------
#	EXPANDER
#--------------------------------------------------
./a83.sh ./ ../src/expander/expander.ads W
./a83.sh ./ ../src/expander/expander.adb w
./a83.sh ./ ../src/expander/expander-utils.adb w
./a83.sh ./ ../src/expander/expander-expressions.adb w
./a83.sh ./ ../src/expander/expander-declarations.adb w
./a83.sh ./ ../src/expander/expander-declarations-types_decls.adb w
./a83.sh ./ ../src/expander/expander-instructions.adb w
./a83.sh ./ ../src/expander/expander-structures.adb w
#--------------------------------------------------
#	ADA_COMP
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/ada_comp.ads W
./a83.sh ./ ../src/ada_comp/ada_comp.adb W

