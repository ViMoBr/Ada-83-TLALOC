separate (auto_control)
procedure helling (h :  in percentage) is
begin
    begin
        if abs (h) > 50 then    -- crash !!
            -- rit afgelopen en niet herstartbaar
            raise CRASH;
        end if;
        new_helling := new_helling+h;
    exception
        when CONSTRAINT_ERROR   =>  if h < 0 then
                                        new_helling := min_helling;
                                    else
                                        new_helling := max_helling;
                                    end if;
        when CRASH              =>  put_tijdstip (clock);
                                    put_speed (0);
                                    put_crash (AAN);
                                    raise;
        when others             =>  raise;
    end;
    update_dynamics;
exception
    when STOPPED    =>  put_message (mk_string("AUTO STAAT STIL !!"));
    when others     =>  raise;
end helling;
                                        
