with text_io;use text_io;
with integer_io;
with getargs; use getargs;
procedure ArgPrt is
    package int_io is new integer_io (integer);
    use int_io;
    np : integer;
    len : integer;
    arg : string (0 .. 100);
begin
    np := NumArgs;
    for i in 0 .. np - 1
    loop
	GetArg (i, arg, len);
	put ("argument ");
	put (i);
	put (" is ");
	put (arg (0 .. len-1));
	put (" met lengte ");
	put (len);
	new_line;
    end loop;
end;
