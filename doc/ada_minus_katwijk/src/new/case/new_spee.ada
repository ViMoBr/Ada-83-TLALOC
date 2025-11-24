separate (auto_control)
function new_speed (delta_t     : duration) return speed is
    -- bereken nieuwe waarde voor snelheid en retourneer deze
    delta_v : speed;
    
    function sabs (sp_val    : in speed) return speed is
    --
    begin
        if sp_val > 0 then
            return sp_val;
        else
            return -sp_val;
        end if;
    end;
begin
    if gas >= 0 then
        if snelheid > 0 then
            delta_v := speed (delta_t) * 
                       (C_m_m * speed (gas) - speed (curr_helling) * G
                      --  -C_w_m * snelheid**2
                      );
        else    -- snelheid =< 0
            delta_v := speed (delta_t) * (C_m_m * speed (gas) -
                        speed (curr_helling) * G
                      -- + C_w_m * snelheid**2
                        );
        end if;
    else
        if snelheid > 0 then
            delta_v := speed (delta_t) * (speed (C_r) * speed (gas) -
                        speed (curr_helling) * G 
                      -- + C_w_m * snelheid**2
                        );
        else -- snelheid <= 0
            delta_v := speed(delta_t) * (-speed (C_r) * speed (gas) -
                        speed (curr_helling) * G 
                      -- + C_w_m * snelheid**2
                        );
        end if;
        if sabs (speed (C_r) * speed (gas)) > sabs (speed (curr_helling) * G)
            then                                                
            if (snelheid + delta_v) >= 0 and snelheid <= 0 then
                raise STOPPED;
            elsif (snelheid + delta_v) <= 0 and snelheid >= 0 then
                raise STOPPED;
            end if;
        end if;
    end if;
    return snelheid+delta_v;
end new_speed;

