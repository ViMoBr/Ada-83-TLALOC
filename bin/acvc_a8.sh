#!/bin/bash
./a83.sh ./ ../acvc83_11/support/repspec.ada W
./a83.sh ./ ../acvc83_11/support/repbody.ada W

# acvc_a8.sh — compile, assemble et exécute la séquence de tests "A8"
# de l'ACVC 1.11 (Ada 83), à la suite de acvc.sh.
#
# Généralise le motif observé dans acvc.sh :
#   - compilation en 2 passes (W puis B) sur TOUS les fichiers, dans l'ordre
#   - puis, dans ADA__LIB : fasmg -> chmod u+x -> exécution, par test
#
# Nouveautés gérées ici :
#   - fichiers .tst (nécessitent MACROSUB -> .adt avant compilation)
#   - test multi-fichiers a28006 (sous-unité "separate")
#
# set -u (pas -e) : une erreur ne doit pas empêcher de tenter les autres tests
set -uo pipefail

SRC_DIR="../acvc83_11/atests/a8"

# Chaque entrée : "NOM_EXE:fichier1[,fichier2,...]"
# Les fichiers d'une même entrée sont listés dans l'ORDRE DE COMPILATION requis.
# NOM_EXE = nom du fichier contenant le sous-programme principal, en
# majuscules, sans extension (c'est ce que fasmg/chmod/exécution utilisent).
TESTS=(
  "A83009A:a83009a.ada"
  "A83009B:a83009b.ada"
  "A83041B:a83041b.ada"
  "A83041C:a83041c.ada"
  "A83041D:a83041d.ada"
  "A83A02A:a83a02a.ada"
  "A83A02B:a83a02b.ada"
  "A83A06A:a83a06a.ada"
  "A83A08A:a83a08a.ada"
  "A83C01C:a83c01c.ada"
  "A83C01D:a83c01d.ada"
  "A83C01E:a83c01e.ada"
  "A83C01F:a83c01f.ada"
  "A83C01G:a83c01g.ada"
  "A83C01H:a83c01h.ada"
  "A83C01I:a83c01i.ada"
  "A83C01J:a83c01j.ada"
  "A85007D:a85007d.ada"
  "A85013B:a85013b.ada"
  "A87B59A:a87b59a.ada"
)

# ---------------------------------------------------------------------
# 1. Macro-substitution : tout .tst doit devenir un .adt avant compilation.
#
#    >>> A ADAPTER : ceci est un STUB. Branchez ici votre véritable appel
#    >>> à MACROSUB (TSTTESTS.DAT + MACRO.DFS configuré pour TLALOC).
#    Tant que ce n'est pas fait, les tests concernés sont simplement ignorés
#    (voir la boucle d'assemblage plus bas) plutôt que de faire planter le lot.
# ---------------------------------------------------------------------
ensure_adt() {
    local tst="$1"
    local adt="${tst%.tst}.adt"
    if [[ -f "$SRC_DIR/$adt" ]]; then
        return 0
    fi
    echo "!! $tst : substitution de macros manquante (attendu : $adt)"
    return 1
}

resolved_name() {
    local f="$1"
    if [[ "$f" == *.tst ]]; then
        echo "${f%.tst}.adt"
    else
        echo "$f"
    fi
}

# ---------------------------------------------------------------------
# 2. Construction de la liste à plat des fichiers à compiler, en ignorant
#    les tests dont un .tst n'est pas encore substitué.
# ---------------------------------------------------------------------
declare -A SKIP
declare -a ALL_FILES

for entry in "${TESTS[@]}"; do
    exe="${entry%%:*}"
    files="${entry#*:}"
    IFS=',' read -ra flist <<< "$files"

    ok=1
    resolved=()
    for f in "${flist[@]}"; do
        if [[ "$f" == *.tst ]]; then
            ensure_adt "$f" || ok=0
        fi
        resolved+=("$(resolved_name "$f")")
    done

    if [[ $ok -eq 1 ]]; then
        ALL_FILES+=("${resolved[@]}")
    else
        SKIP[$exe]="substitution de macros manquante"
    fi
done

# ---------------------------------------------------------------------
# 3. Compilation en deux passes (W puis B) sur l'ensemble du lot, dans
#    l'ordre — identique au principe de acvc.sh, mais sur toute la liste.
# ---------------------------------------------------------------------
for pass in W B; do
    for f in "${ALL_FILES[@]}"; do
        ./a83.sh ./ "$SRC_DIR/$f" "$pass"
    done
done

# ---------------------------------------------------------------------
# 4. Assemblage + exécution, test par test.
#
#    >>> Hypothèse pour le test multi-fichiers (a28006) : fasmg n'a besoin
#    >>> que du .fas de l'unité PRINCIPALE (A28006D0M.fas) pour lier le
#    >>> programme complet — la sous-unité A28006D1 étant déjà dans la
#    >>> bibliothèque ADA__LIB après la passe B. A vérifier sur votre
#    >>> installation TLALOC si ça ne lie pas.
# ---------------------------------------------------------------------
cd ./ADA__LIB || exit 1

for entry in "${TESTS[@]}"; do
    exe="${entry%%:*}"
    if [[ -n "${SKIP[$exe]:-}" ]]; then
        echo "-- $exe ignoré (${SKIP[$exe]})"
        continue
    fi
    echo "== $exe =="
    ./fasmg "${exe}.fas" "$exe"
    chmod u+x "$exe"
    ./"$exe"
done
