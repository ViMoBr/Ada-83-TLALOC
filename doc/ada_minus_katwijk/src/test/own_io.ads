package own_io is
   MAX_STRING: constant integer := 512;
   procedure get_line (s: out string; cnt : in out integer);
   procedure put_line (s: string);
end;

