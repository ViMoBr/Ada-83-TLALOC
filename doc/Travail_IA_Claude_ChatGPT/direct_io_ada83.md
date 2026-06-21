# Une lecture inexploitée de `DIRECT_IO` en Ada 83
## Du *contract model* à la persistance d'objets typés : sur une régression silencieuse d'Ada 95

*Ébauche, [auteur], avril 2026*

---

## Résumé

La doctrine établie veut que le package générique `DIRECT_IO` du LRM Ada 83 ne puisse être instancié qu'avec des types de taille fixe, à l'exclusion des types indéfinis tels que `STRING` ou les records à discriminants sans valeur par défaut. Cette doctrine, gravée dans la syntaxe d'Ada 95 par l'introduction du marqueur `(<>)`, est en réalité une *jurisprudence d'implémenteurs* plutôt qu'une exigence de la norme originelle. Une lecture attentive du LRM 83 — corroborée par le *Rationale* d'Ichbiah, Barnes, Firth et Woodger — montre qu'aucune disposition n'interdit explicitement de telles instanciations : la limitation découle uniquement du *contract model* du chapitre 12, et seulement dans la mesure où le corps du générique nécessite la déclaration d'objets non contraints du type formel. Or rien n'oblige `DIRECT_IO` à le faire. Au moins un compilateur Ada 83 validé — le Karlsruhe Ada System de SYSTEAM (1987) — a effectivement exploité cette latitude. Nous soutenons que cette possibilité, conceptuellement riche, ouvre la voie à une lecture de `DIRECT_IO` et `SEQUENTIAL_IO` comme *substrats de persistance d'objets typés*, dans la lignée des systèmes à blocs mobiles (Resource Manager Macintosh) ou des images Smalltalk-80. Ce que la révision Ada 95 a clos par souci de rigueur formelle, elle l'a clos sur une richesse architecturale qu'il vaut la peine, aujourd'hui, de réexaminer.

---

## 1. La question

Le LRM Ada 83 définit, au §14.2.4, le package générique `DIRECT_IO` :

```ada
generic
   type ELEMENT_TYPE is private;
package DIRECT_IO is
   ...
end DIRECT_IO;
```

Le paramètre formel est un `private` simple. La question, en apparence triviale, est de savoir si l'instanciation suivante est légale en Ada 83 :

```ada
package P is new DIRECT_IO (STRING);
```

La réponse usuellement donnée est : *non, parce que `DIRECT_IO` exige des éléments de taille fixe*. Cette réponse, telle qu'on la trouve par exemple dans le GNAT Reference Manual sous la formulation *« Direct_IO can only be instantiated for definite types. This is a restriction of the Ada language »*, est rétrospective : elle reformule l'état d'Ada 95 et le projette sur Ada 83. Une lecture stricte du chapitre 14 du LRM 83 ne contient aucune interdiction de cette nature.

## 2. Ce que dit (et ne dit pas) le LRM 83

Le §14.2 du LRM 83 décrit la sémantique opérationnelle de `DIRECT_IO` — accès indexé par numéro d'enregistrement, opérations `READ`/`WRITE` avec un paramètre `POSITIVE_COUNT`, fonction `SIZE`, etc. — sans jamais imposer de contrainte sur la taille des éléments. Le terme « definite » n'apparaît pas ; il n'apparaît dans aucun document normatif d'Ada 83, étant un apport terminologique d'Ada 95. Le §14.2.4(2) lui-même se contente de présenter la spécification du package, sans exiger que `ELEMENT_TYPE` soit contraint.

L'interdiction prétendue ne découle donc, dans le cadre Ada 83, que d'un raisonnement indirect via le chapitre 12, c'est-à-dire via le *contract model* des génériques.

## 3. Le contract model d'Ada 83 et sa porosité revendiquée

Le *contract model* d'Ada 83 stipule que pour qu'un type actuel soit acceptable comme correspondance à un paramètre formel `private`, toutes les opérations effectuées sur le formel à l'intérieur du gabarit générique doivent rester légales lorsqu'on substitue l'actuel.

Le point critique, pour ce qui nous occupe, est qu'Ada 83 — contrairement à Ada 95 — n'oblige pas le concepteur d'un générique à *annoncer* dans la spécification s'il déclarera ou non des objets non contraints du type formel dans le corps. La conséquence est claire : la légalité d'une instanciation peut dépendre du contenu du corps. Si le corps contient quelque part `X : ELEMENT_TYPE;`, alors une instanciation avec `STRING` sera rejetée ; sinon, elle peut être acceptée.

Ce point n'est pas une lecture audacieuse de notre part. Il est explicitement reconnu par les auteurs du langage. Le *Ada 83 Rationale* (§12.4, « Rationale for the Formulation of Generic Units ») énonce :

> *« One limitation of the contract model concerns the ability to declare unconstrained objects. […] An instantiation with an unconstrained array type such as [STRING] will not work since a declaration of an unconstrained variable […] would not be allowed. […] This limitation means that some instantiations may be rejected on the grounds that the body requires the ability to declare unconstrained objects of the formal type. We have considered this consequence to be preferable to an increase in the complexity of the syntax. »*

Trois points méritent d'être soulignés dans ce passage.

D'abord, Ichbiah et ses co-auteurs reconnaissent ouvertement que la « limitation » est *contingente au corps du générique*. Elle n'est pas absolue.

Ensuite, ils décrivent la situation comme une « limitation » et non comme une règle de sûreté. Le ton est celui d'une concession, pas d'un principe.

Enfin, ils justifient ce choix par un refus délibéré d'alourdir la syntaxe — refus qu'Ada 95 abandonnera. Le marqueur `(<>)` introduit en Ada 95 est précisément l'ajout syntaxique qu'Ada 83 avait écarté.

## 4. Conséquence pour `DIRECT_IO` : la latitude est réelle

Le corps de `DIRECT_IO` n'est *pas tenu* de déclarer une variable non contrainte de `ELEMENT_TYPE`. Toutes les opérations exposées prennent l'élément comme paramètre formel (`in` ou `out`) :

```ada
procedure READ  (FILE : in  FILE_TYPE; ITEM : out ELEMENT_TYPE);
procedure WRITE (FILE : in  FILE_TYPE; ITEM : in  ELEMENT_TYPE);
```

Les paramètres formels ne nécessitent pas de contrainte au moment de la déclaration : ils sont contraints par l'objet réel passé à l'appel. Une implémentation peut donc parfaitement opérer sur la zone mémoire pointée par le paramètre, ou utiliser `Unchecked_Conversion` vers une représentation octet, sans jamais déclarer localement une variable nue de `ELEMENT_TYPE`.

Il s'ensuit qu'une implémentation conforme au LRM 83 peut accepter `package P is new DIRECT_IO (STRING);` à condition d'organiser son corps en évitant les déclarations non contraintes du type formel — et à condition de gérer, dans la représentation persistante, des enregistrements de taille variable.

## 5. Le précédent de Karlsruhe : la preuve par l'exemple

Cette latitude n'est pas hypothétique. Elle a été exploitée. Le 22 avril 1987, Peter Dencker (SYSTEAM KG, Karlsruhe) publie sur `comp.lang.ada` un message intitulé *« VAX Ada sequential IO and Direct IO »* dans lequel il démontre que le **Karlsruhe Ada System version 1.6A** — un compilateur Ada 83 validé pour VAX/VMS — accepte sans erreur :

```ada
TYPE foo(a : integer) IS
   RECORD
      f1 : string (1..a);
   END RECORD;

PACKAGE seq_io IS NEW sequential_io (foo);
PACKAGE dir_io  IS NEW direct_io  (foo);
```

Le programme test, reproduit intégralement dans le post, écrit alternativement des éléments de tailles 3 et 4 caractères, les relit séquentiellement, accède aux index 18 et 15 dans un fichier dont le `Create` utilise le paramètre `form` :

```ada
form => "ORGANIZATION => INDEXED, RECORD_FORMAT => VARIABLE"
```

L'exécution réussit. Le journal de compilation publié atteste *« No Errors during Compilation »* sur le Karlsruhe Ada System 1.6A. Le post de Dencker est explicitement présenté comme une réponse à des utilisateurs de **VAX Ada (DEC)** qui rencontraient des problèmes — DEC ayant, lui, choisi la voie restrictive. On a donc, dès 1987, une divergence d'implémentation entre deux compilateurs validés sur le même sujet, divergence que la norme ne permettait pas de trancher.

L'astuce d'implémentation est révélatrice : Dencker s'appuie sur le *Record Management Services* (RMS) de VMS, qui offre nativement des fichiers indexés à enregistrements de longueur variable. C'est là un point notable : la fonctionnalité de stockage persistant à granularité variable existait au niveau OS, et il suffisait à l'implémenteur Ada de la traverser.

## 6. La sémantique latente : `DIRECT_IO` comme store d'objets typés

Acceptons un instant le point de vue permissif. Que signifie `DIRECT_IO (STRING)` ?

L'objet ainsi obtenu est un *store persistant indexé* : une suite numérotée de chaînes de longueurs arbitraires, à laquelle on peut accéder par numéro, et qu'on peut modifier en place — un `WRITE` à l'index *N* peut écraser un élément de longueur différente, ce qui implique un repositionnement (compactage, fragmentation, ou indirection via une table d'index).

Ce mécanisme est familier. On le retrouve, sous des noms divers :

- dans le **Resource Manager** de Macintosh classique, où chaque ressource est un quadruplet `(type, ID, taille, données)` accessible par index, avec compactage périodique du fichier `.rsrc` ;
- dans les **images Smalltalk-80** (puis Squeak), qui stockent des objets de tailles diverses indexés par OID, avec compactage à la charge du GC ;
- dans la **table xref des fichiers PDF**, qui mappe un numéro d'objet à son offset dans le fichier ;
- dans les **bases de données objet** des années 90 (ObjectStore, Versant, O2), qui ont précisément vendu la persistance d'objets typés à grain variable comme une innovation ;
- plus modestement dans les **fichiers VMS RMS indexés**, qui offrent ce service au niveau OS.

L'analogie n'est pas une fantaisie rétrospective. Elle est *consubstantielle* à l'idée d'un accès indexé à des éléments de taille variable. Et `DIRECT_IO`, dans la lecture permissive du LRM 83, est exactement cela.

Pousser un cran plus loin : instanciée avec un record à discriminants variables — disons un type arbre étiqueté ou un nœud d'AST — la même machinerie offre un véritable *object store* persistant à types riches, en pur Ada 83, sans extension du langage. La parenté avec la sérialisation d'objets de Java (1997) ou les bases d'objets persistants modernes est frappante. Ada 83 contenait, latente, la brique conceptuelle.

## 7. L'apport et la régression d'Ada 95

Ada 95 a tranché la question, et l'a tranchée dans les deux directions à la fois.

D'un côté, l'introduction du marqueur `(<>)` dans la déclaration des paramètres formels privés résout proprement la « porosité » du *contract model* d'Ada 83. La légalité d'une instanciation devient déterminable à partir de la seule spécification du générique, sans dépendance au corps. C'est un gain de rigueur formelle indéniable, et le *Rationale* d'Ada 95 le revendique comme tel : *« This new distinction […] eliminates the major gap in the generic contract model of Ada 83. »*

De l'autre, le choix opéré pour `DIRECT_IO` ne garde *pas* le marqueur `(<>)`. L'AARM 95, dans la justification du §A.8.4, est explicite :

> *« The Element_Type formal of Direct_IO does not have an unknown_discriminant_part (unlike Sequential_IO) so that the implementation can make use of the ability to declare uninitialized variables of the type. »*

La formulation est révélatrice. Le choix n'est pas justifié par une nécessité sémantique, ni par une impossibilité conceptuelle d'un `DIRECT_IO` à éléments variables, mais par une *commodité d'implémentation*. C'est le compilateur, non le langage, qu'on cherche à simplifier. Ada 95 grave dans la syntaxe ce qui n'était, en 83, qu'une option choisie par certains implémenteurs. La voie de Karlsruhe, et ce qu'elle ouvrait, est interdite — non parce qu'elle était illégale, mais parce qu'elle compliquait le runtime.

C'est, à notre sens, une régression. Elle pétrifie une lecture culturelle minoritaire de la norme et ferme une porte conceptuelle. Le fait qu'elle soit accompagnée de l'introduction de `Stream_IO` — qui résout *autrement* le problème de la persistance hétérogène — n'efface pas l'amputation : `Stream_IO` est un autre objet, avec d'autres invariants (notamment, pas d'accès direct par index sur des éléments de taille variable sans table externe). Le `DIRECT_IO` permissif d'Ada 83, lui, *unifiait* l'accès indexé et la taille variable. Cette unité a disparu.

## 8. Une intuition d'architecte

Il y a quelque chose de typiquement *ichbiahéen* dans cette latitude. Jean Ichbiah, ancien concepteur de **LIS** (*Language d'Implémentation de Systèmes*) chez CII Honeywell Bull, avait une compréhension de l'architecture système qui dépassait largement la culture pédagogique des langages de l'époque. LIS, dès le début des années 1970, manipulait des notions — paquetages, types abstraits, encapsulation — qui ne se généraliseraient que vingt ans plus tard. La porosité assumée du *contract model* d'Ada 83 procède d'un même mouvement : préférer une norme qui *autorise plus* qu'une norme qui *garantit plus*, même au prix de portabilités imparfaites.

L'équipe d'Ada 9X, formée dans une autre époque et soumise à d'autres impératifs (validation formelle, certifiabilité, prévisibilité), n'a pas vu — ou a choisi de ne pas voir — la richesse architecturale qu'elle fermait. Cela n'enlève rien à la qualité technique d'Ada 95. Mais le geste mérite d'être nommé : c'est une *clôture par incompréhension d'une finesse*, comme il en advient régulièrement dans l'histoire des langages — on en trouverait d'autres exemples avec les coroutines de Simula 67, les continuations de Scheme, ou la sémantique des modules de Standard ML.

## 9. Implications pour aujourd'hui

Pour qui réimplémente Ada 83 — ce qui est rare, mais pas inexistant : nous citerons en particulier le compilateur expérimental TLALOC, dont la conception nous a conduit à reposer ces questions — la lecture permissive du LRM 83 offre une voie pédagogique et architecturale précieuse.

Implémenter `DIRECT_IO (STRING)` ou `DIRECT_IO (T)` pour un `T` à discriminants variables, c'est :

- montrer concrètement la sémantique du *contract model* d'Ada 83 et ses zones grises ;
- exposer la parenté entre I/O persistante et gestion mémoire (table d'index, compactage, locking) ;
- fournir un substrat de persistance d'objets typés sans sortir du langage standard ;
- documenter, par l'exemple, une lecture du langage qui a existé historiquement mais que la révision a effacée.

La position raisonnable, dans un contexte d'enseignement ou de recherche, n'est ni la rigueur sourde (« on rejette parce que les autres rejettent »), ni la permissivité aveugle, mais l'**explicitation du choix** : accepter, en émettant un avertissement sur la non-portabilité, et documenter la stratégie d'implémentation retenue.

## 10. Conclusion

`DIRECT_IO` en Ada 83 est plus qu'une primitive d'I/O : c'est, dans la lecture permise par la norme et exemplifiée par le Karlsruhe Ada System, une porte vers la persistance d'objets typés à grain variable. Cette lecture, légitime au regard du LRM 83 et explicitement reconnue par le *Rationale* d'Ichbiah et al., a été refermée par Ada 95 pour des raisons d'implémentation. Il y a là une histoire à raconter, et peut-être, pour les implémenteurs d'aujourd'hui, une voie à rouvrir.

---

## Références

1. **LRM Ada 83** — *Reference Manual for the Ada Programming Language*, ANSI/MIL-STD-1815A, février 1983. Voir notamment les chapitres 12 (Generic Units) et 14 (Input-Output). Version archivée : `http://archive.adaic.com/standards/83lrm/html/`

2. **Ada 83 Rationale** — Ichbiah, J. D., Barnes, J. G. P., Firth, R. J., Woodger, M., *Rationale for the Design of the Ada Programming Language*, 1986. Section 12.4 « Rationale for the Formulation of Generic Units », passage explicite sur la limitation du *contract model* concernant les objets non contraints. Version archivée : `http://archive.adaic.com/standards/83rat/html/ratl-12-04.html`

3. **Dencker, P.** — Message sur `comp.lang.ada`, *« VAX Ada sequential IO and Direct IO »*, 22 avril 1987. SYSTEAM KG, Karlsruhe Ada System version 1.6A pour VAX/VMS. Source primaire : code de test `unconstr_io.ada` instanciant `direct_io` avec un record à discriminant variable, journal de compilation et trace d'exécution. Archive Google Groups : `https://groups.google.com/g/comp.lang.ada/c/MxZ_CZ435aM`

4. **Ada 95 Rationale** — Barnes, J. G. P. (éd.), *Ada 95 Rationale*, Intermetrics, 1995. Partie II, chapitres 3 (types) et 12 (génériques). Discussion explicite du *« major gap in the generic contract model of Ada 83 »* et de la solution apportée par le marqueur `(<>)`.

5. **AARM 95**, §A.8.4 *The Generic Package Direct_IO*, justification du choix de ne pas autoriser de partie discriminant inconnue : *« so that the implementation can make use of the ability to declare uninitialized variables of the type »*.

6. **AdaCore Gem #46**, *Incompatibilities between Ada 83 and Ada 95*, exposé pédagogique moderne du même point. `https://www.adacore.com/blog/gem-46`

7. **GNAT Reference Manual**, chapitre *The Implementation of Standard I/O*, formulation rétrospective : *« Direct_IO can only be instantiated for definite types. This is a restriction of the Ada language. »* Cette formulation, vraie pour Ada 95+, est fréquemment projetée à tort sur Ada 83.

8. **Ichbiah, J. D.** — Travaux antérieurs sur **LIS** (Language d'Implémentation de Systèmes), CII Honeywell Bull, années 1970, comme contexte intellectuel de la conception d'Ada 83. Voir notamment Ichbiah et al., *« Rationale for the Design of the Green Programming Language »*, ACM SIGPLAN Notices, 1979.

9. **Inside Macintosh, Volume II**, *The Memory Manager* et *The Resource Manager*, Apple Computer, 1985. Description canonique d'un système à blocs mobiles à handles avec compactage, comme analogue contemporain de l'implémentation que pourrait avoir un `DIRECT_IO` permissif.

---

*Notes pour la suite : ce texte est une ébauche. À développer notamment :*
*— une comparaison plus fine entre la stratégie « Karlsruhe / RMS indexé » et une stratégie « table xref en queue à la PDF » ;*
*— l'examen détaillé du corps de `DIRECT_IO` tel qu'écrit pour TLALOC, montrant qu'aucune déclaration non contrainte n'apparaît ;*
*— un examen symétrique du cas `SEQUENTIAL_IO`, qu'Ada 95 a au contraire ouvert avec `(<>)`, et de la dissymétrie résultante ;*
*— une éventuelle reconstitution archivistique d'autres compilateurs Ada 83 (Alsys, Verdix, Janus, TeleSoft, Rational R1000) pour cartographier qui acceptait quoi.*
