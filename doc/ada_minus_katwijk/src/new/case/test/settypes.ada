
generic
   type elem is (<>);
package settypes is
   type set is private;

   function null_set return set;
   function "*" (x, y: set) return set;
   function "+" (x, y: set) return set;
   function "+" (x: set; y: elem) return set;
   function "+" (x: elem; y: set) return set;
   function "-" (x, y: set) return set;
   function "-" (x: set; y: elem) return set;
   function "-" (x: elem; y: set) return set;

   function "<" (x, y: set) return boolean;
   function is_empty (x: set) return boolean;

   function is_member (x: set; y: elem) return boolean;

private
   type set is array (elem) of boolean;
end;
package body settypes is
   function null_set return set is
   begin
      return (others => false);
   end;

   function "*" (x, y: set) return set is
   begin
      return x and y;
   end;

   function "+" (x, y: set) return set is
   begin
      return x or y;
   end;

   function "+" (x: set; y: elem) return set is
      z : set;
   begin
      z := x;
      z (y) := true;
      return z;
   end;

   function "+" (x: elem; y: set) return set is
      z : set;
   begin
      return y + x;
   end;
      

   function "-" (x, y: set) return set is
      z : set;
   begin
      z := x;
      for i in z' range loop
         z (i) := not y (i);
      end loop;
      return z;
   end;

   function "-" (x: set; y: elem) return set is
      z : set := x;
   begin
      z (y) := false;
      return z;
   end;

   function "-" (x: elem; y: set) return set is
   begin
      return y - x;
   end;

   function "<" (x, y: set) return boolean is
      z : set := x and y;
   begin
      return (z = x) and (z /= y);
   end;

   function is_empty (x: set) return boolean is
   begin
      for i in x' range loop
         if x (i)
         then
            return false;
         end if;
      end loop;
      return true;
   end;

   function is_member (x: set; y: elem) return boolean is
   begin
      return x (y);
   end;

end settypes;

