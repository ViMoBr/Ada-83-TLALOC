-- Programme Ada 83 pour exécuter une commande shell
-- Compilation: gnatmake shell_exec.adb
-- Exécution: ./shell_exec

with Text_IO; use Text_IO;

procedure Shell_Exec is

			--------
  package			OS_SHELL
  is			--------

    procedure EXECUTE	( COMMANDE :);
	--------
  end	OS_SHELL;
	--------

			--------
  package	body		OS_SHELL
  is			--------

   function System (Command : String) return Integer;
   pragma Import (C, System, "system");

	--------
  end	OS_SHELL;
	--------


   -- Fonction C pour exécuter une commande système

   Command : String (1 .. 256);
   Last : Natural;
   Status : Integer;

begin
   Put_Line ("Programme d'exécution de commandes shell");
   Put_Line ("=========================================");
   New_Line;

   -- Exemple avec une commande constante
   Put_Line ("Exécution d'une commande prédéfinie: ls -la");
   Status := System ("ls -la" & ASCII.NUL);
   Put_Line ("Code de retour: " & Integer'Image(Status));
   New_Line;

   -- Lecture d'une commande au clavier
   Put_Line ("Entrez une commande shell à exécuter:");
   Put ("> ");
   Get_Line (Command, Last);

   if Last > 0 then
      Put_Line ("Exécution de: " & Command(1..Last));
      New_Line;

      -- Ajouter le caractère nul pour C
      Status := System (Command(1..Last) & ASCII.NUL);

      New_Line;
      Put_Line ("Code de retour: " & Integer'Image(Status));
   else
      Put_Line ("Aucune commande entrée.");
   end if;

end Shell_Exec;
