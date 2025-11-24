separate (auto_control)
procedure reset_dynamics is
    -- initialiseer de toestands vectoren
begin
    dyn_obj := initial_dyn_obj;
    new_dyn_obj := initial_dyn_obj;
    tijdstip := clock;
    new_tijdstip := tijdstip;
    put_all (dyn_obj);
    put_message (mk_string("                     "));
end reset_dynamics;

