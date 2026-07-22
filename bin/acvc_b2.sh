#!/bin/bash
./a83.sh ./ ../acvc83_11/support/repspec.ada W
./a83.sh ./ ../acvc83_11/support/repbody.ada W

# acvc_b2.sh — compile, assemble et exécute la séquence de tests "B2"
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

SRC_DIR="../acvc83_11/btests/b2"

# Chaque entrée : "NOM_EXE:fichier1[,fichier2,...]"
# Les fichiers d'une même entrée sont listés dans l'ORDRE DE COMPILATION requis.
# NOM_EXE = nom du fichier contenant le sous-programme principal, en
# majuscules, sans extension (c'est ce que fasmg/chmod/exécution utilisent).
TESTS=(
"B22001A:b22001a.adt"
"B22001B:b22001b.adt"
"B22001C:b22001c.adt"
"B22001D:b22001d.adt"
"B22001E:b22001e.adt"
"B22001F:b22001f.adt"
"B22001G:b22001g.adt"
"B22001H:b22001h.ada"
"B22001I:b22001i.adt"
"B22001J:b22001j.adt"
"B22001K:b22001k.adt"
"B22001L:b22001l.adt"
"B22001M:b22001m.adt"
"B22001N:b22001n.adt"
"B22003A:b22003a.ada"
"B22003B:b22003b.ada"
"B22004A:b22004a.ada"
"B22004B:b22004b.ada"
"B22004C:b22004c.ada"
"B22005A:b22005a.ada"
"B22005B:b22005b.ada"
"B22005C:b22005c.ada"
"B22005D:b22005d.ada"
"B22005E:b22005e.ada"
"B22005F:b22005f.ada"
"B22005G:b22005g.ada"
"B22005H:b22005h.ada"
"B22005I:b22005i.ada"
"B22005J:b22005j.ada"
"B22005K:b22005k.ada"
"B22005L:b22005l.ada"
"B22005M:b22005m.ada"
"B22005N:b22005n.ada"
"B22005O:b22005o.ada"
"B22005P:b22005p.ada"
"B22005Q:b22005q.ada"
"B22005R:b22005r.ada"
"B22005S:b22005s.ada"
"B22005T:b22005t.ada"
"B22005U:b22005u.ada"
"B22005V:b22005v.ada"
"B22005W:b22005w.ada"
"B22005X:b22005x.ada"
"B22005Y:b22005y.ada"
"B22005Z:b22005z.ada"
"B23002A:b23002a.ada"
"B23003D:b23003d.adt"
"B23003E:b23003e.adt"
"B23003F:b23003f.adt"
"B23004A:b23004a.ada"
"B23004B:b23004b.ada"
"B24001A:b24001a.ada"
"B24001B:b24001b.ada"
"B24001C:b24001c.ada"
"B24005A:b24005a.ada"
"B24005B:b24005b.ada"
"B24007A:b24007a.ada"
"B24009A:b24009a.ada"
"B24104A:b24104a.ada"
"B24204A:b24204a.ada"
"B24204B:b24204b.ada"
"B24204C:b24204c.ada"
"B24204D:b24204d.ada"
"B24204E:b24204e.ada"
"B24204F:b24204f.ada"
"B24205A:b24205a.ada"
"B24206A:b24206a.ada"
"B24206B:b24206b.ada"
"B24211B:b24211b.ada"
"B25002A:b25002a.ada"
"B25002B:b25002b.ada"
"B25004B:b25004b.ada"
"B26001A:b26001a.ada"
"B26002A:b26002a.ada"
"B26005A:b26005a.ada"
"B27005A:b27005a.ada"
"B28001A:b28001a.ada"
"B28001B:b28001b.ada"
"B28001C:b28001c.ada"
"B28001D:b28001d.ada"
"B28001E:b28001e.ada"
"B28001F:b28001f.ada"
"B28001G:b28001g.ada"
"B28001H:b28001h.ada"
"B28001I:b28001i.ada"
"B28001J:b28001j.ada"
"B28001K:b28001k.ada"
"B28001L:b28001l.ada"
"B28001M:b28001m.ada"
"B28001N:b28001n.ada"
"B28001O:b28001o.ada"
"B28001P:b28001p.ada"
"B28001Q:b28001q.ada"
"B28001R:b28001r.ada"
"B28001S:b28001s.ada"
"B28001T:b28001t.ada"
"B28001U:b28001u.ada"
"B28001V:b28001v.ada"
"B28001W:b28001w.ada"
"B28003A:b28003a.ada"
"B28003C:b28003c.ada"
"B28006A:b28006a.ada"
"B28006C:b28006c.adt"
"B28006E:b28006e.ada"
"B28006F0M:b28006f0m.adt"
"B28006F1:b28006f1.adt"
"B29001A:b29001a.ada"
"B2A003A:b2a003a.ada"
"B2A003B:b2a003b.ada"
"B2A003C:b2a003c.ada"
"B2A003D:b2a003d.ada"
"B2A003E:b2a003e.ada"
"B2A003F:b2a003f.ada"
"B2A004A:b2a004a.ada"
"B2A005A:b2a005a.ada"
"B2A005B:b2a005b.ada"
"B2A007A:b2a007a.ada"
"B2A010A:b2a010a.ada"
"B2A021A:b2a021a.ada"
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
