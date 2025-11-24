with car;
with garage; use garage;
with text_io; use text_io;
--with integer_io;
with enumeration_io;
--with io_hulp; use io_hulp;
procedure main is
--    type garage_akties is (buy, sell, show, build_in, tour, stop);
--    package aktie_io is new enumeration_io (garage_akties);
--    aktie   : garage_akties;
begin
    put_line ("Auto beheer voor een garage");
    put_line ("Open data base");
    open_db_input;
    --
--    loop
        put_line ("De mogelijke akties die U kunt uitvoeren zijn:");
--        for i in garage_akties
--      loop
--        aktie_io. put (standard_output, i);
--            put (" ");
--        end loop;
        put ("Welke aktie kiest U ? ");
--        aktie_io. get (aktie);
--        case aktie is
--            when buy =>
                buy_car;
--            when sell =>
----                sell_car;
--                    null;
--            when show =>
                show_unsold_cars (car. automerk);
--            when build_in =>
----                build_in_snuf (
--                    null;
--            when tour =>
--                    null;
----                make_a_tour (
--            when stop =>
--                put_line ("Data base will be cleaned and closed");
--                exit;
--        end case;
--    end loop;
    -- close database
    close_data_base;
end main;
