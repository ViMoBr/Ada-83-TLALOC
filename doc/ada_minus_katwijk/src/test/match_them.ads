with own_io;
with pattern_making;
use pattern_making;
package match_them is
   My_Error: exception;
   function Matches (l: string; p: pattern) return boolean;
end match_them;
