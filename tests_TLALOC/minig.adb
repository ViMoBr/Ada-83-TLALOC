procedure MINIG is
  V : STRING (1 .. 4);
  generic
    type T3 is array (POSITIVE range <>) of CHARACTER;
  procedure P;
  procedure P is
    S : T3 (1 .. 2);
  begin
    declare
    begin
      S := S;        -- uplevel depuis le bloc : force le chemin absolu a travers P
    end;
  end P;

begin
  null;
end MINIG;
