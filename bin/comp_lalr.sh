#!/bin/bash
debutC=$(date +%s)


./comp_predef_units.sh
#--------------------------------------------------
#	IDL
#--------------------------------------------------
./a83.sh ./ ./idl_tools/lalridl_node_attr_class_names.ads W

./a83.sh ./ ../src/lalr_tools/idl.ads W
./a83.sh ./ ../src/lalr_tools/idl.adb W
./a83.sh ./ ../src/communs/idl-page_man.adb W
./a83.sh ./ ../src/communs/idl-idl_tbl.adb W
./a83.sh ./ ../src/communs/idl-idl_man.adb W
./a83.sh ./ ../src/communs/idl-print_nod.adb W
./a83.sh ./ ../src/par_phase/grmr_tbl.ads W
./a83.sh ./ ../src/par_phase/grmr_ops.ads W
./a83.sh ./ ../src/par_phase/grmr_ops.adb W
./a83.sh ./ ../src/par_phase/lex.ads W
./a83.sh ./ ../src/par_phase/lex.adb W

./a83.sh ./ ../src/lalr_tools/idl-check_grmr.adb W
./a83.sh ./ ../src/lalr_tools/idl-init_grmr.adb W
./a83.sh ./ ../src/lalr_tools/idl-lalr_grmr.adb W
./a83.sh ./ ../src/lalr_tools/idl-load_grmr.adb W
./a83.sh ./ ../src/lalr_tools/idl-optr_grmr.adb W
./a83.sh ./ ../src/lalr_tools/idl-print_stat.adb W
./a83.sh ./ ../src/lalr_tools/idl-read_grmr.adb W
./a83.sh ./ ../src/lalr_tools/idl-stat_grmr.adb W
./a83.sh ./ ../src/lalr_tools/idl-term_list.adb W
./a83.sh ./ ../src/lalr_tools/lalr_tools.adb W


finC=$(date +%s)
dureeC=$((finC - debutC))

heuresC=$((dureeC / 3600))
minutesC=$(((dureeC % 3600) / 60))
secondesC=$((dureeC % 60))

printf "Durée de compilation : %02dh %02dmin %02dsec\n" "$heuresC" "$minutesC" "$secondesC"

./a83.sh ./ ../src/lalr_tools/lalr_tools.adb B

if [ $1="A" ]; then

cd ./ADA__LIB
debutA=$(date +%s)

./fasmg -v 2 LALR_TOOLS.fas LALR_TOOLS >lalr_tools_map.txt

finA=$(date +%s)
dureeA=$((finA - debutA))

heuresA=$((dureeA / 3600))
minuteA=$(((dureeA % 3600) / 60))
secondesA=$((dureeA % 60))

printf "Durée d assemblage : %02dh %02dmin %02dsec\n" "$heuresA" "$minutesA" "$secondesA"
fi


