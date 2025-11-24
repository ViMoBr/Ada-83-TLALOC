package body pattern_making is
-- a simple reader structure

type string_reader is record
     pattern_string:  string (1 .. 512);
     index:           integer;
end record;
reader : string_reader;

function current_character return character is
   c: character := reader. pattern_string (reader. index);
begin
   if c = character' val (0)
   then
      return EOP;
   else
      return c;
   end if;
end;

function read_character return character is
   c: character := reader. pattern_string (reader. index);
begin
   if current_character = EOP
   then
      return EOP;
   else
      reader. index := reader. index + 1;
      return c;
   end if;
end;

function reader_exhausted return boolean is
begin
   return current_character = EOP;
end;

procedure init_reader (s: string) is
begin
   for i in s' range loop
      reader. pattern_string (i) := s (i);
   end loop;
   reader. pattern_string (s' last + 1) := character' val (0);
   reader. index := 1;
end;




function get_slot (slot_key: key_kind) return pattern is
   t : pattern;
begin
   t := new pattern_element (slot_key);
   t. next := null;
   return t;
end;



function Closure_Element (t: pattern) return pattern is
   f : pattern := get_slot (clos_key);
begin
   f. low_val := t;
   return f;
end;

function Make_Closure_Last_Element (t: pattern) return pattern is
begin
   if t. next = null   -- end of the line
   then
      return Closure_Element (t);
   else
      t. next := Make_Closure_Last_Element (t. next);
      return t;
   end if;
end;

function Add_Last_Element (t: pattern; e: pattern) return pattern is
begin
   if t = null
   then
      return e;
   else
      t. next := Add_Last_Element (t. next, e);
      return t;
   end if;
end;


function Make_Char (c: character) return pattern is
   p : pattern;
begin
   p := get_slot (char_key);
   p. pattern_char_value := c;
   return p;
end;



function Expand_Class (c1 : character;
                       c2 : character;
                       tl : pattern) return pattern is
   hd : pattern := Make_Char (c1);
begin
   ada_io. put (c1); ada_io. put (' '); ada_io.put (c2); 
   ada_io. put (character' val (13)); ada_io. put (character' val (10));
   if c1 >= c2
   then
      hd. next := tl;
   else
      hd. next := Expand_Class (character' succ (c1), c2, tl);
   end if;
   return hd;
exception
   when others => 
   ada_io. put (c1); ada_io. put (' '); ada_io.put (c2); 
   ada_io. put (character' val (13)); ada_io. put (character' val (10));
   raise;
end;
   
function Get_CCL return pattern is
   p1 : pattern;
   c1,
   c2 : character;
begin
   c1 := read_character;
   if c1 = EOP or else c1 = BUS_CHAR
   then
      return null;
   end if;
   c2 := current_character;
   if c2 = '-'
   then
      c2 := read_character; c2 := read_character;
      if c2 = EOP
      then
         c2 := c1;
      end if;
      p1 := Get_CCL;
      p1 := Expand_Class (c1, c2, p1);
   else
      p1 := make_Char (c1);
      p1. next := Get_CCL;
   end if;
   return p1;
end;

function Make_CCL return pattern is
   p : pattern;
begin
   p := get_slot (ccl_key);
   p. low_val := Get_CCL;
   return p;
end;




function Make_Element return pattern is
   c : character := read_character;
   p : pattern;
begin
   case c is
      when ANY_CHAR     => return get_slot (any_key);
      when BOL_CHAR     => return get_slot (bol_key);
      when EOL_CHAR     => return get_slot (eol_key);
      when ESCAPE_CHAR  => return Make_Char (read_character);
      when SUB_CHAR     => return Make_CCL;
      when others       => return Make_Char (c);
   end case;
end;


function Parse_Pattern (t: pattern) return pattern is
   dummy: character;
begin
   if reader_exhausted
   then
      return t;
   elsif current_character = CLOS_CHAR
   then
      dummy := read_character;
      return Parse_Pattern (Make_Closure_Last_Element (t));
   else
      return Parse_Pattern (Add_Last_Element (t, Make_Element));
   end if;
end;

procedure Print_Pattern (p: pattern) is
   procedure print_class (patel: pattern) is
      l : pattern := patel;
   begin
      while l /= null loop
         put (l. pattern_char_value);
         l := l. next;
      end loop;
   end;

   procedure print_it (patel: pattern) is
      l : pattern := patel;
   begin
      while l /= null loop
         case l. pattern_key is
            when bol_key     => put (BOL_CHAR);
            when eol_key     => put (EOL_CHAR);
            when any_key     => put (ANY_CHAR);
            when char_key    => put (l. pattern_char_value);
            when clos_key    => print_it (l. low_val);
                                put (CLOS_CHAR);
            when ccl_key     => put (SUB_CHAR);
                                print_class (l. low_val);
                                put (BUS_CHAR);
            when others      => put ('+');
         end case;
         l := l. next;
      end loop;
   end;
begin
   put (character' val (10));
   print_it (p);
   put (character' val (10));
end;




function Make_Pattern (s: string; f: boolean) return pattern is
   p : pattern := null;
begin
   init_reader (s);
   p := Parse_Pattern (p);
   if f
   then
      Print_Pattern (p);
   end if;
   return p;
end;
end;
