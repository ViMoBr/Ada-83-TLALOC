with text_io;use text_io;
with integer_io;
procedure testio is
    package int_io is new integer_io(integer);
    use int_io;
begin
    put_line ("Een regel uitprinten");
    put ('a');
    put ('z');
    put (10);
end;

