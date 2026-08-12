#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------
# diff_finc_predef.sh -- ORACLE DE POINT FIXE sur les unites predefinies :
# compiler chaque unite avec T1 et avec T2, comparer les FINC produits.
# Identite attendue a la fin de ligne pres (piege n 131 : CRLF).
# Toute divergence = miscompilation latente de T2, MEME si la compilation
# "passe" (le n 145 a vecu ainsi).
#
# A AJUSTER : les 4 variables ci-dessous selon votre arborescence.
#-----------------------------------------------------------------------------------------------------------------------

T1=./a83.sh                 # compilateur reference (TLALOC-gnat)
T2=./ADA__LIB/T2                     # compilateur bootstrappe
SRC=./                      # repertoire des sources predefinies
OUT=./diff_finc             # zone de travail (creee/ecrasee)

UNITS="_standrd.ads system.ads machine_code.ads calendar.ads io_exceptions.ads \
text_io.ads direct_io.ads sequential_io.ads unchecked_conversion.ads unchecked_deallocation.ads \
_standrd.adb calendar.adb text_io.adb direct_io.adb sequential_io.adb"

rm -rf   "$OUT"
mkdir -p "$OUT/t1" "$OUT/t2"
REPORT="$OUT/RAPPORT.txt"
: > "$REPORT"

NB_ID=0 ; NB_DIFF=0 ; NB_ERR=0

for U in $UNITS ; do
  for SIDE in t1 t2 ; do
    W="$OUT/$SIDE/${U%.*}_${U##*.}"                       # un repertoire par unite et par bord
    mkdir -p "$W"
    ( cd "$W" || exit 1
      if [ "$SIDE" = t1 ] ; then CC="$OLDPWD/$T1" ; else CC="$OLDPWD/$T2" ; fi
      "$CC" ./ "$OLDPWD/$SRC/$U" W > compile.log 2>&1     # meme commande des deux cotes
    )
  done

  W1="$OUT/t1/${U%.*}_${U##*.}" ; W2="$OUT/t2/${U%.*}_${U##*.}"

  # ---- inventaire des FINC produits (noms identiques attendus) ----
  L1=$(cd "$W1" && ls *.FINC *.finc 2>/dev/null | sort)
  L2=$(cd "$W2" && ls *.FINC *.finc 2>/dev/null | sort)

  if [ -z "$L1" ] || [ -z "$L2" ] ; then
    echo "$U : ERREUR (FINC absent d'un cote -- voir compile.log)" | tee -a "$REPORT"
    NB_ERR=$((NB_ERR+1)) ; continue
  fi
  if [ "$L1" != "$L2" ] ; then
    echo "$U : DIVERGENT (inventaires de FINC differents)"          | tee -a "$REPORT"
    diff <(echo "$L1") <(echo "$L2")                                >> "$REPORT"
    NB_DIFF=$((NB_DIFF+1)) ; continue
  fi

  # ---- diff fichier a fichier, CRLF normalise (n 131) ----
  U_OK=1
  for F in $L1 ; do
    if ! diff <(tr -d '\r' < "$W1/$F") <(tr -d '\r' < "$W2/$F") > "$OUT/last.diff" 2>&1 ; then
      U_OK=0
      echo "$U / $F : DIVERGENT"                                    | tee -a "$REPORT"
      echo "  premieres lignes du diff :"                           >> "$REPORT"
      head -30 "$OUT/last.diff" | sed 's/^/  /'                     >> "$REPORT"
      cp "$OUT/last.diff" "$OUT/${U%.*}_${U##*.}__${F}.diff"        # diff complet conserve
    fi
  done

  if [ "$U_OK" = 1 ] ; then
    echo "$U : IDENTIQUE ($(echo "$L1" | wc -l) FINC)"              | tee -a "$REPORT"
    NB_ID=$((NB_ID+1))
  else
    NB_DIFF=$((NB_DIFF+1))
  fi
done

echo "------------------------------------------------------------"  | tee -a "$REPORT"
echo "BILAN : $NB_ID identiques, $NB_DIFF divergentes, $NB_ERR en erreur" | tee -a "$REPORT"
if [ "$NB_DIFF" = 0 ] && [ "$NB_ERR" = 0 ] ; then
  echo "POINT FIXE PREDEFINIS : ATTEINT"                             | tee -a "$REPORT"
else
  echo "POINT FIXE PREDEFINIS : NON ATTEINT -- diffs complets dans $OUT" | tee -a "$REPORT"
fi
