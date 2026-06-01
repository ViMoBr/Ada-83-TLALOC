with Unchecked_Deallocation;
with Text_IO;
with System;
procedure Main is

   Loop_Error : exception;

   S : String (1 .. 128) := (others => '#');
   L : Natural := 0;

   type Depth_Type is range 0 .. 9000;

   type Depth_Count is range 0 .. System.Max_Int;

   package Dpth_IO is new Text_IO.Integer_IO (Depth_Type);

   package Deco_IO is new Text_IO.Integer_IO (Depth_Count);

   F : Text_IO.File_Type;

   function Get_Number_Of_Measurements return Depth_Count is
      type Loop_Index is range 1 .. System.Max_Int;
      Last : Depth_Count := 0;
      Unused_Depth : Depth_Type;
   begin
      Text_IO.Open (File => F,
                    Mode => Text_IO.In_File,
                    Name => S (1 .. L));
      for I in Loop_Index range 1 .. System.Max_Int loop
         exit when Text_IO.End_Of_File (F);
         Dpth_IO.Get (File => F,
                      Item => Unused_Depth);
         Last := Last + 1;
      end loop;
      if not Text_IO.End_Of_File (F) then
         raise Loop_Error;
      end if;
      Text_IO.Close (F);
      return Last;
   end Get_Number_Of_Measurements;

   procedure Run is

      N : constant Depth_Count := Get_Number_Of_Measurements;

      subtype Depth_Index is Depth_Count range 1 .. Depth_Count'Last;

      type Depth_Array is array (Depth_Index range <>) of Depth_Type;

      procedure Run_Main (Depth : in out Depth_Array) is
         Number_Of_Increases : Depth_Count := 0;
         D : Depth_Array renames Depth;
      begin
         Text_IO.Open (File => F,
                       Mode => Text_IO.In_File,
                       Name => S (1 .. L));

         for I in Depth_Index range 1 .. D'Last loop
            Dpth_IO.Get (File => F,
                         Item => D (I));
         end loop;
         Text_IO.Close (F);

         for I in Depth_Index range 2 .. D'Last loop
            if D (I) > D (I - 1) then
               Number_Of_Increases := Number_Of_Increases + 1;
            end if;
         end loop;
         Text_IO.Put ("Answer: ");
         Deco_IO.Put (Item  => Number_Of_Increases,
                      Width => 0);
         Text_IO.New_Line;
      end Run_Main;

      procedure Use_File is
         type Depth_Access is access Depth_Array;

         D : Depth_Access;

         procedure Free is new Unchecked_Deallocation
           (Object => Depth_Array,
            Name   => Depth_Access);
      begin
         D := new Depth_Array (1 .. N);
         Run_Main (D.all);
         Free (D);
      exception
         when others =>
            Free (D);
            raise;
      end Use_File;

      procedure Read_Text_File is
      begin
         Use_File;
         if Text_IO.Is_Open (F) then
            Text_IO.Close (F);
         end if;
      exception
         when others =>
            if Text_IO.Is_Open (F) then
               Text_IO.Close (F);
            end if;
            raise;
      end Read_Text_File;

   begin
      Read_Text_File;
   end Run;

begin
   Text_IO.Get_Line (S, L);
   --  Put (S (1 .. L));
   --  New_Line;
   case L is
      when 0 =>
         Text_IO.Put ("Specify one command argument, the input file.");
         Text_IO.New_Line;
         return;
      when others => Run;
   end case;
end Main;
