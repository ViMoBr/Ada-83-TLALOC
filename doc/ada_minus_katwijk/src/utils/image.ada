-- Dit gaat fout

with text_io; use text_io;
-- test image attribute

procedure image is
    a   : integer;
begin
    a := 10;
    put_line (integer'image (a));
end;
