/*
  Bepaal aantal registers voor leaf node, zoals name, icon, fcon, reg, oreg.

  Deze beschrijven door de 680x0 altijd direct addresseerbare
  lokatie's of konstante's.
  Hiervoor zijn dus geen hulpregisters nodig.
  De aantallen registers worden op 0 geinit.

  NB. we gaan ervanuit, dat een registervariable eerst naar een ander
  Register wordt gemoved, voordat erin gerekend wordt.
  Als tweede lid van een expressie is hij echter altijd direkt
  addresseerbaar, net als een geheugenplaats.
*/

/*
  Bepaal het aantal registers voor een unary mul node.
  (Een waarde lezen van of schrijven naar een berekend adres.)

  Wanneer het een offset tov. een address register betreft,
  is de geheugeninhoud direkt te adresseren,
  waardoor dus geen hulpregister nodig is.

  Als dit niet het geval is en het adres moet berekend worden,
  dan wordt de waarde direkt addresseerbaar via een adresregister.
*/

/*
  Bepaal hoeveel registers voor het vertalen van een assign node nodig zijn.

  Wanneer het eerste lid een direkt adresseerbare geheugenplaats is,
  dan gaan we ervanuit, dat de node als volgt vertaald wordt:
  - Vertaal rechterlid, met resultaat in register.
  - Move het resultaat naar de geheugenplaats.
  In dit geval is het aantal registers van het rechterlid nodig, met een
  minimum van 1 voor het resultaatregister.

  Wanneer het linkerlid via een adresregister adresseerbaar is, dan gaan
  we ervanuit, dat de vertaling wordt:
  - Vertaal het linkerlid naar een adresregister.
  - Vertaal het rechterlid naar een register.
  - Move het resultaat via het adresregister.
  In dit geval is het maximum van de benodigde registers van de subleden
  nodig, waarbij het aantal adresregisters voor het tweede lid
  met 1 verhoogd is.

  Wanneer we ook het genereren van revassign-node's toestaan,
  is de volgende vertaling mogelijk:
  - Vertaal rechterlid naar register.
  - Vertaal adressering van linkerlid naar adresregister.
  - Move resultaat via adresregister.
  Waarbij het aantal registers gelijk is aan het maximum van de subleden,
  waarbij bij het aantal registers van het linkerlid, 1 is bijgeteld,
  bij het type registers waarin het resultaat zit.
*/

/*
  Bepaal het aantal benodigde registers voor een call-node.

  We gaan ervanuit, dat d0 en fp0 door de aangeroepen funktie niet intakt
  gelaten worden, omdat ze mogelijke resultaattypen zijn.

  Wanneer het resultaat een adres (maar toch in r0) is, dan gaan we
  ervanuit, dat deze direkt na de funktieaanroep gemoved wordt naar een
  adresregister, waardoor dus ook een adresregister nodig is.

  Aangezien het vroeger gebruikelijk was (bij ontbreken van een fpu),
  om een double in r0,r1 terug te geven, gaan we ervanuit, dat deze beide
  registers vernield kunnen zijn.

  Na het bepalen van deze aantallen, dient nog het maximum met dat van de
  parameterlijst en met dat van de funktieadresbepaling bepaald te worden.

  Wanneer we geen revcall-node ervan mogen maken, dient er in geval van een
  berekend adres ook nog een adresregister voor tijdens het aanmaken van de
  argumenten gereserveerd te worden.
*/

/*
  Bepaal het aantal registers voor een incr- of decr-node.

  We gaan ervanuit, dat het als volgt vertaald wordt:
  - move ea,rx
  - addq/subq #n,ea
  Er is dus minstens een register nodig voor de vertaling.

  Het volgende kan als adresseringswijze ((An)+) vertaald worden:
  uny-*
    incr
      reg regnr
      icon n
  Dat zou bij de vertaling van de uny-* herkend moeten worden.
  Hier zien we voor de overzichtelijkheid en overdraagbaarheid vanaf,
  aangezien er maar 1 register meer nodig is bij de algemene vertaalwijze.

  We gaan ervanuit, dat de rechtersubexpressie altijd konstant is.
*/

/*
  Bepaal aantal registers voor sconv-node.

  Er zijn 3 gevallen te onderscheiden:
  - Wanneer de breedte afneemt, hoeft eigenlijk alleen het adres maar
