--
-- test van sequential_io
--
with sequential_io, text_io;
--
procedure testseq is
    type int_rec is
    record
        getal1,
        getal2 :    integer;
    end record;
    
    aap :   int_rec;
    package seq_rec is new sequential_io (int_rec);
    
    use seq_rec;
    fd      : file_type;
    --
begin
    open (fd, OUT_FILE, "seq_test");
    for i in 1 .. 10
    loop
        aap. getal1 := i;
        aap. getal2 := i + 10;
        write (fd, aap);
    end loop;
    reset (fd, IN_FILE);
    for i in 1 .. 10
    loop
        read (fd, aap);
        text_io. put (integer' image (aap. getal1));
        text_io. put (integer' image (aap. getal2));
    end loop;
end;        
            
