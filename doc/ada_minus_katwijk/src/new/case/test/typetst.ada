-- test van generic package settypes
--
with text_io, settypes;
use text_io;
with integer_io;
--
procedure typetst is
    subtype tst_int is integer range 0..5;
    package tst_int_ins is new settypes (tst_int);
    use tst_int_ins;
    type speed is range 0..300;
    sp  : speed := 5;
    package int_io is new integer_io (integer);
    use int_io;
    subtype tst_set is set;
    --
    a, b, c     : tst_set;
    procedure out_speed (sp : speed) is separate;
begin
    a := null_set;
    b := a;
    a := a + 1;
    a := a + 3;
    c := a;
    for i in tst_int
    loop
        if is_member (a, i) then
            put ("member ");
            put (integer (sp));
            out_speed (sp);
            put_line (tst_int'image (i));
        else
            put ("no member ");
            put_line (tst_int'image (i));
        end if;
    end loop;
end;

separate (typetst)
procedure out_speed (sp     : speed) is
begin
    put (integer (sp));
    put (integer (sp));
end;
