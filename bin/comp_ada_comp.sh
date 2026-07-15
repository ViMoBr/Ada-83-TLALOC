#!/bin/bash
debutC=$(date +%s)


./comp_predef_units.sh
#--------------------------------------------------
#	IDL
#--------------------------------------------------
./a83.sh ./ ./idl_tools/diana_node_attr_class_names.ads W
./a83.sh ./ ../src/ada_comp/idl.ads W
./a83.sh ./ ../src/ada_comp/idl.adb W

./a83.sh ./ ../src/communs/idl-page_man.adb W
./a83.sh ./ ../src/communs/idl-idl_tbl.adb W
./a83.sh ./ ../src/communs/idl-idl_man.adb W
./a83.sh ./ ../src/communs/idl-print_nod.adb W
./a83.sh ./ ../src/pretty/idl-pretty_diana.adb W
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
./a83.sh ./ ../src/ada_comp/idl-lib_phase.adb W
#--------------------------------------------------
#	SEM_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/sem_phase/idl-sem_phase.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-aggreso.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-att_walk.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-chk_stat.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-def_util.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-def_walk.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-derived.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-eval_num.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-exp_type.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-expreso.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-fix_pre.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-fix_with.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-gen_subs.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-hom_unit.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-instant.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-make_nod.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-newsnam.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-nod_walk.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-pra_walk.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-pre_fcns.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-red_subp.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-rep_clau.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-req_util.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-sem_glob.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-set_util.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-stm_walk.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-uarith.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-univ_ops.adb W
./a83.sh ./ ../src/sem_phase/idl-sem_phase-vis_util.adb W
#--------------------------------------------------
#	ERR_PHASE
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-err_phase.adb W
#--------------------------------------------------
#	WRITE_LIB
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/idl-write_lib.adb W
#--------------------------------------------------
#	EXPANDER
#--------------------------------------------------
./a83.sh ./ ../src/expander/expander.ads W
./a83.sh ./ ../src/expander/expander.adb W
./a83.sh ./ ../src/expander/expander-utils.adb W
./a83.sh ./ ../src/expander/expander-expressions.adb W
./a83.sh ./ ../src/expander/expander-declarations.adb W
./a83.sh ./ ../src/expander/expander-declarations-types_decls.adb W
./a83.sh ./ ../src/expander/expander-represented_items.adb W
./a83.sh ./ ../src/expander/expander-instructions.adb W
./a83.sh ./ ../src/expander/expander-structures.adb W
#--------------------------------------------------
#	ADA_COMP
#--------------------------------------------------
./a83.sh ./ ../src/ada_comp/ada_comp.ads W
./a83.sh ./ ../src/ada_comp/ada_comp.adb W


finC=$(date +%s)
dureeC=$((finC - debutC))

heuresC=$((dureeC / 3600))
minutesC=$(((dureeC % 3600) / 60))
secondesC=$((dureeC % 60))

printf "Durée de compilation : %02dh %02dmin %02dsec\n" "$heuresC" "$minutesC" "$secondesC"

if $1='A'
then

cd ./ADA__LIB
debutA=$(date +%s)

./fasmg ADA_COMP.fas ADA_COMP

finA=$(date +%s)
dureeA=$((finA - debutA))

heuresA=$((dureeA / 3600))
minuteA=$(((dureeA % 3600) / 60))
secondesA=$((dureeA % 60))

printf "Durée d assemblage : %02dh %02dmin %02dsec\n" "$heuresA" "$minutesA" "$secondesA"
fi
