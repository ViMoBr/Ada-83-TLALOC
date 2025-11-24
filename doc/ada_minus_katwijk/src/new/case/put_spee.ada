separate (display_handler)
procedure put_speed (v  : in  speed) is
--    vv  : speed := v * 100.0/28.0;  --schaaleinde correspondeert
    vv  : speed := v * 10000/28;  --schaaleinde correspondeert
    -- met +100 cq -100 km/u uitgaande van speed in m/s
    xx  : speed := vv;
begin
    mk_invis;
    if vv > 10000 then
        vv := 10000;
    end if;
    if vv < -10000 then
        vv := -10000;
    end if;
    move_rc (4, 10);
    put (integer (xx));
--    put (speed 'image (xx));
    move_rc (4, 28);
    put_bar ('X', ' ', percentage (vv));
    old_dyn .snelheid := vv;
    move_prompt;
    mk_vis;
end put_speed;

