separate (auto_control)
procedure update_dynamics is
begin
    new_tijdstip := clock;
    new_snelheid := updated_speed (new_tijdstip);
    dyn_obj := new_dyn_obj;
    put_all (dyn_obj);
exception
    when STOPPED    =>  new_snelheid := 0;
                        dyn_obj := new_dyn_obj;
                        put_all (dyn_obj);
                        raise;
    when others     => raise;
end update_dynamics;

