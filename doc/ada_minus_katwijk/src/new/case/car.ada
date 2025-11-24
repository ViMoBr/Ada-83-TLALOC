with text_io; use text_io;
with integer_io;
with enumeration_io;
with settypes;

package car is

   type autorec is private;

   subtype merktype	is string (1 .. 10);
   subtype florijn	is integer;
   subtype afstand	is integer;
   type snuf		is (tv, radio, telefoon, cr_c);

   package snuf_instant	is new settypes (snuf);
   subtype snufset	is snuf_instant. set;
   type statustype	is (te_koop, verkocht, verloren_gegaan);
   subtype jaartype	is integer;
   subtype ident	is string (1 .. 8);
   subtype zwaarte	is positive;
   subtype power	is integer;

   use snuf_instant;

   package getal_io is new integer_io (integer);

   package status_io  is new enumeration_io (car. statustype);

   package florijn_io renames getal_io;
   package afstand_io renames getal_io;
   package jaar_io renames getal_io;
   package zwaarte_io renames getal_io;
   package power_io renames getal_io;

   type componenten   is (automerk,
                          auto_type,
                          inkoopprijs,
                          verkoopprijs,
                          bouwjaar,
                          km_stand,
                          snufs,
                          status,
                          kenteken,
                          gewicht,
                          kracht);

   error_1: exception;
   type vstring is access standard. string;

   function mk_string (s: string) return vstring;

   procedure read (auto: in out autorec;
                   from: in file_type);

   procedure read_tty (auto    : in out autorec);
    
   procedure write (auto: in autorec;
                    to:   file_type := standard_output);

   procedure write_head (to:	file_type := standard_output);

   function relation (auto_1, auto_2: autorec;
                      criterium:  componenten) return boolean;



   function get_automerk	(auto:	autorec) return merktype;
   function get_auto_type	(auto:	autorec) return merktype;
   function get_inkoopprijs	(auto:	autorec) return florijn;
   function get_verkoopprijs	(auto:	autorec) return florijn;

   function get_bouwjaar	(auto:	autorec) return jaartype;
   function get_km_stand	(auto:	autorec) return afstand;

   function get_snufs		(auto:	autorec) return snufset;
   function get_status		(auto:	autorec) return statustype;
   function get_kenteken	(auto:	autorec) return ident;
   function get_gewicht		(auto:	autorec) return zwaarte;
   function get_kracht		(auto:	autorec) return power;


   procedure set_automerk	(auto:	in out autorec; merk:	merktype);
   procedure set_auto_type	(auto:	in out autorec; atype:	merktype);
   procedure set_inkoopprijs	(auto:	in out autorec; i_prijs:	florijn);
   procedure set_verkoopprijs	(auto:	in out autorec;
                                 v_prijs:	florijn);

   procedure set_bouwjaar	(auto:	in out autorec;
                    		 b_jaar:	jaartype);
   procedure set_km_stand	(auto:	in out autorec;
                     		 km_stand: afstand);
   procedure set_snufs		(auto:	in out autorec;
                    		 snufs:	snufset);
   procedure set_status		(auto:	in out autorec;
                         	 status:	statustype);
   procedure set_kenteken	(auto:	in out autorec;
                    		 kent:	ident);
   procedure set_gewicht	(auto:	in out autorec;
                        	 gewicht:	zwaarte);
   procedure set_kracht		(auto:	in out autorec;
                     		 pk:	power);

private
   type autorec is record
	automerk:	merktype;
	auto_type:	merktype;
	inkoopprijs:	florijn;
	verkoopprijs:	florijn;
	bouwjaar:	jaartype;
	km_stand:	afstand;
	snufs:		snufset;
	status:		statustype;
	kenteken:	ident;
	gewicht:	zwaarte;
	kracht:		power;
   end record;
end car;

with io_hulp;
package body car is

   function mk_string (s: string) return vstring is
      t: vstring;
   begin
      t := new string (s' range);
      t. all := s;
      return t;
   end;

   use io_hulp;
   function relation (auto_1, auto_2:	autorec;
                      criterium:	componenten) return boolean is
   begin
      case criterium is
         when automerk =>
           return auto_1. automerk < auto_2. automerk;

         when auto_type =>
           return auto_1. auto_type < auto_2. auto_type;

         when inkoopprijs =>
           return auto_1. inkoopprijs < auto_2. inkoopprijs;

         when verkoopprijs =>
           return auto_1. verkoopprijs < auto_2. verkoopprijs;

         when bouwjaar =>
           return auto_1. bouwjaar < auto_2. bouwjaar;

         when km_stand =>
           return auto_1. km_stand < auto_2. km_stand;

         when status =>
	   return auto_1. status < auto_2. status;

         when gewicht =>
           return auto_1. gewicht < auto_2. gewicht;

         when others =>
           raise error_1;

      end case;
   end;

   procedure read (auto:	in out autorec;
                   from:	file_type) is
   begin
      get (from, string (auto. automerk));

      get (from, string (auto. auto_type));

      getal_io. get (from, auto. inkoopprijs);

      getal_io. get (from, auto. verkoopprijs);

      getal_io. get (from, auto. km_stand);

      declare
         bit: integer;
      begin
         getal_io. get (from, bit);

         if bit = 1 then
            auto. snufs := auto. snufs + TV;
         end if;

         getal_io. get (from, bit);

         if bit = 1 then
            auto. snufs := auto. snufs + RADIO;
         end if;

         getal_io. get (from, bit);

         if bit = 1 then
            auto. snufs := auto. snufs + TELEFOON;
         end if;

         getal_io. get (from, bit);

         if bit = 1 then
            auto. snufs := auto. snufs + CR_C;
         end if;
      end;

      status_io. get (from, auto. status);
      getal_io. get (from, auto. bouwjaar);
      get (from, string (auto. kenteken));
      put (string (auto .kenteken));
      getal_io. get (from, auto. gewicht);
      getal_io. get (from, auto. kracht);
   end read;

   procedure read_tty (auto: in out autorec) is
      last: natural;
   begin
      put ("automerk?");    -- string io
      get_line (string (auto. automerk), last);
      for i in last + 1 .. car. merktype' last loop
         auto. automerk (i) := ' ';
      end loop;

      put ("auto_type?");
      get_line (string (auto. auto_type), last);
      for i in last + 1 .. car. merktype' last loop
         auto. auto_type (i) := ' ';
      end loop;

      put ("inkoopprijs ?");
      getal_io. get (auto. inkoopprijs);

      put ("verkoopprijs ?");
      getal_io. get (auto. verkoopprijs);

      put ("km_stand ?");
      getal_io. get (auto. km_stand);

      auto .snufs := null_set;
      put ("Has the vehicle snufs like: (answer yes or no please)");
      new_line (1);
      skip_line;

      put ("TV ");
      if io_hulp. get_yes_or_no = YES then
         auto. snufs := auto. snufs + TV;
      end if;

      put ("RADIO ");
      if io_hulp. get_yes_or_no = YES then
         auto. snufs := auto. snufs + RADIO;
      end if;

      put ("TELEFOON ");
      if io_hulp. get_yes_or_no = YES then
         auto. snufs := auto. snufs + TELEFOON;
      end if;

      put ("CR_C ");
      if io_hulp. get_yes_or_no = YES then
         auto. snufs := auto. snufs + CR_C;
      end if;

      new_line (1);

      put ("status ?");
      status_io. get (auto. status);

      put ("bouwjaar ?");
      getal_io. get (auto. bouwjaar);

      put ("kenteken ?");
      get (string (auto. kenteken));

      put ("gewicht ?");
      getal_io. get (auto. gewicht);

      put ("vermogen ?");
      getal_io. get (auto. kracht);
   end;

   procedure write (auto: in autorec;
                    to:   file_type := standard_output) is
   begin
      -- assume 132 positions

      set_line_length (to => 132);
      set_col         (to => 1);
      put             (to, string (auto. automerk));

      set_col         (to => 11);
      put             (to, string (auto. auto_type));

      set_col         (to => 21);
      getal_io. put   (to, auto.inkoopprijs);

      set_col         (to => 36);
      getal_io. put   (to, auto. verkoopprijs);

      set_col         (to => 51);
      getal_io. put   (to, auto. km_stand, width => 7);

      set_col         (to => 61);
      -- put snufset as a bitmap

      if is_member (auto. snufs, TV) then
         put (to, "1 ");
      else
         put (to, "0 ");
      end if;
      if is_member (auto. snufs, RADIO) then
         put (to, "1 ");
      else
         put (to, "0 ");
      end if;
      if is_member (auto. snufs, TELEFOON) then
         put (to, "1 ");
      else
         put (to, "0 ");
      end if;
      if is_member (auto. snufs, CR_C) then
         put (to, "1 ");
      else
         put (to, "0 ");
      end if;

      set_col         (to => 71);
      status_io. put  (to, auto. status, width => 10);

      set_col         (to => 81);
      getal_io. put   (to, auto. bouwjaar, width => 4);

      set_col         (to => 91);
      put             (to, string (auto. kenteken));

      set_col         (to => 101);
      getal_io. put   (to, auto. gewicht, width => 5);

      set_col         (to => 111);
      getal_io. put   (to, auto. kracht);

      new_line (1);
   end;

   procedure write_head (to: file_type := standard_output) is
   begin
      set_line_length (to => 132);

      set_col         (to => 1);
      put             (to, "merk");

      set_col         (to => 11);
      put             (to, "type");

      set_col         (to => 21);
      put             (to, "inkoop");

      set_col         (to => 36);
      put             (to, "verkoop");

      set_col         (to => 51);
      put             (to, "km_stand");

      set_col         (to => 61);
      put             (to, "snufs");

      set_col         (to => 71);
      put             (to, "status");

      set_col         (to => 81);
      put             (to, "bouwjaar");

      set_col         (to => 91);
      put             (to, "kenteken");

      set_col         (to => 101);
      put             (to, "gewicht");

      set_col         (to => 111);
      put             (to, "pk's");

      new_line (1);
      for i in 1 .. 131 loop
         put (to, '-');
      end loop;
      new_line (3);
   end write_head;

   function get_automerk (auto: autorec) return merktype is
   begin
      return auto. automerk;
   end;

   function get_auto_type (auto: autorec) return merktype is
   begin
      return auto. auto_type;
   end;

   function get_inkoopprijs (auto: autorec) return florijn is
   begin
      return auto. inkoopprijs;
   end;

   function get_verkoopprijs (auto: autorec) return florijn is
   begin
      return auto. verkoopprijs;
   end;

   function get_bouwjaar (auto: autorec) return jaartype is
   begin
      return auto. bouwjaar;
   end;

   function get_km_stand (auto: autorec) return afstand is
   begin
      return auto. km_stand;
   end;

   function get_snufs (auto: autorec) return snufset is
   begin
      return auto. snufs;
   end;

   function get_status (auto: autorec) return statustype is
   begin
      return auto. status;
   end;

   function get_kenteken (auto: autorec) return ident is
   begin
      return auto. kenteken;
   end;

   function get_gewicht (auto: autorec) return zwaarte is
   begin
      return auto. gewicht;
   end;

   function get_kracht (auto: autorec) return power is
   begin
      return auto. kracht;
   end;

   procedure set_automerk (auto: in out autorec;
                            merk: merktype) is
   begin
      auto. automerk := merk;
   end;

   procedure set_auto_type (auto: in out autorec;
                            atype: merktype) is
   begin
      auto. auto_type := atype;
   end;

   procedure set_inkoopprijs (auto: in out autorec;
                              i_prijs: florijn) is
   begin
      auto. inkoopprijs := i_prijs;
   end;

   procedure set_verkoopprijs (auto: in out autorec;
                               v_prijs: florijn) is
   begin
      auto. verkoopprijs := v_prijs;
   end;

   procedure set_bouwjaar (auto: in out autorec;
                           b_jaar: jaartype) is
   begin
      auto. bouwjaar := b_jaar;
   end;

   procedure set_snufs (auto:  in out autorec;
                        snufs: snufset) is
   begin
      auto. snufs := snufs;
   end;

   procedure set_status (auto: in out autorec;
                         status: statustype) is
   begin
      auto. status := status;
   end;

   procedure set_kenteken (auto:  in out autorec;
                           kent:  ident) is
   begin
      auto. kenteken := kent;
   end;

   procedure set_gewicht (auto: in out autorec;
                          gewicht: zwaarte) is
   begin
      auto. gewicht := gewicht;
   end;

   procedure set_kracht (auto: in out autorec;
                         pk:   power) is
   begin
      auto. kracht := pk;
   end;
end car;

