procedure EXC_TEST0 is
   MON_ERREUR : exception;

   procedure LEVE is
   begin
      raise MON_ERREUR;                    -- raise nommé, propagation sortante
   end LEVE;

begin
   begin
      raise MON_ERREUR;                    -- raise + handler local au bloc
   exception
      when MON_ERREUR => null;             -- choice_exp
   end;

   begin
      LEVE;                                -- propagation inter-frames
   exception
      when CONSTRAINT_ERROR => null;       -- prédéfinie non appariée...
      when others          => null;        -- ...rattrapée par others
   end;
end EXC_TEST0;
