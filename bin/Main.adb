with Text_IO;
procedure Main is

type Enum_Type is
(A,
B,
C,
D,
E);

package Enum_IO is new Text_IO.Enumeration_IO (Enum_Type);
use Enum_IO;

begin
  for Index in A..E loop
    PUT( Index );
  end loop;
end Main;
