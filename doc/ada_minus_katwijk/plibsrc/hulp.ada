
--
-- **********************************************************
-- * Ada PTS timer module                                   *
-- * avoids problems with inaccurate clocks                 *
-- **********************************************************
with text_io;
use text_io; with integer_io;
package timer is
   timer_inaccurate:	exception;
   subtype period is long;

   procedure Start_clock;
   function Elapsed return period;
   function resolution return period;

   package time_io is new integer_io (period);
end timer;

package body timer is
   type proc_time_buffer is record
      proc_user_time :		long;
      proc_system_time:		long;
      child_user_time :		long;
      child_system_time:	long;
   end record;

   procedure $times (t: in out proc_time_buffer);
   init: boolean := false;
   tim :	proc_time_buffer;
   start_time:	long;
   procedure start_clock is
   begin
      $times (tim);
      start_time := tim. proc_user_time;
      init := true;
   end;

   function elapsed return period is
   begin
      $times (tim);
      return tim. proc_user_time - start_time;
   end;

   function resolution return period is
   begin
      return 50;
   end;
end;


with text_io; use text_io;
with timer;   use timer;
with integer_io;

procedure test_6_5 is
   use timer. time_io;
   package int_io renames timer. time_io;
   use int_io;

   subtype positive is long range 0 .. long 'last;
   time_after:	period;
   result,
   nr_calls,
   i:		positive;

   function ackermann (n, m: positive) return positive is
   begin
      if n = 0 then
         return m + 1;
      elsif m = 0 then
         return ackermann (n - 1, 1);
      else
         return ackermann (n - 1, ackermann (n, m - 1));
      end if;
   end ackermann;

begin
   put_line ("Start TEST_6_5.");

   i := 1;
   while 4 ** (i - 1) < long' last / 512 loop

      start_clock;
      result := ackermann (3, I);
      time_after := elapsed;

      if result /= 8 * 2 ** i - 3 then
         put_line ("Function result is wrong");
      end if;

      nr_calls := (128 * 4 ** i - 120 * 2 ** i + 9 * i + 37) / 3;
      put ("For ackermann (3, ");

      put (i);
      put ("):"); new_line;
      put ("Number of calls is ");
      put (nr_calls);
      new_line;
      put ("time per call (in micro-seconds) is ");
      put (1000 * time_after * 50 / nr_calls);
      new_line;
      i := i + 1;
   end loop;

   put ("end test_6_5.");
   new_line (2);

exception
   when storage_error =>
      new_line;
      put ("Storage space exhausted for ackermann (3, ");
      put (i);
      put (");");
      new_line;
end test_6_5;
------------------------------------------------------------------------
------------------------------------------------------------------------

with text_io; use text_io;
with timer;
-----------------------------------------------------------
--                                                       --
--     DHRYSTONE benchmark program
--                                                       --
--     version Ada-, adapted from CACM oktober 84       --
--                                                       --
--     used to compare PCC and EM code generators        --
--     in the DAS compiler                               --
-----------------------------------------------------------
   package global_def is
	-- global definitions
	type enumeration is	(ident_1, ident_2, ident_3, ident_4, ident_5);

	subtype one_to_thirty	is integer range 1 .. 30;
	subtype one_to_fifty 	is integer range 1 .. 50;
	subtype capital_letter	is character; -- range 'A' .. 'Z';

	type string_30		is array (one_to_thirty) of character;

	-- pragma Pack (string_30);

	type array_1_dim_integer is array (one_to_fifty) of integer;
	type array_2_dim_integer is array (one_to_fifty,
	                                   one_to_fifty) of integer;

	type record_type (discr:	enumeration);
	type record_pointer	is access record_type;
	type record_type (discr: enumeration) is
	record
		pointer_comp:	record_pointer;
		case discr is
		when ident_1	=> -- only this variant is used
				   -- but in some cases discriminant
				   -- checks are necessary
			enum_comp : enumeration;
			int_comp  : one_to_fifty;
			string_comp : string_30;

		when ident_2	=>
			enum_comp_2: enumeration;
			string_comp_2: string_30;
		when others	=>
			char_comp_1,
			char_comp_2 : character;
		end case;
	end record;

end global_def;

with global_def; use global_def;

package pack_1 is

	procedure proc_0;
	procedure proc_1 (pointer_par_in:	in record_pointer);
	procedure proc_2 (int_par_in_out:	in out one_to_fifty);
	procedure proc_3 (pointer_par_out:	out record_pointer);
	
	int_glob : integer;
end pack_1;

with global_def; use global_def;
with pack_1;
package pack_2 is
	procedure proc_6 (enum_par_in:		in enumeration;
			  enum_par_out:		out enumeration);
	procedure proc_7 (int_par_in_1,
			  int_par_in_2:		in one_to_fifty;
			  int_par_out:		out one_to_fifty);
	procedure proc_8 (array_par_in_out_1:	in out array_1_dim_integer;
			  array_par_in_out_2:	in out array_2_dim_integer;
			  int_par_in_1,
			  int_par_in_2:		in integer);

	function func_1  (char_par_in_1,
			  char_par_in_2:	in capital_letter)
						return enumeration;

	function func_2  (string_par_in_1,
			  string_par_in_2:	in string_30)
						return boolean;
end pack_2;

with global_def, pack_1;
use global_def;
with timer;
with text_io;
procedure main is
begin
   ----------------------------------------------------------------
   --                                                         --

   --	START TIMER HERE                                      --
   ----------------------------------------------------------------
   timer. start_clock;
   for i in 1 .. 1000
   loop
        pack_1. proc_0;
   end loop;
   -----------------------------------------------------------
   --                                                    --
   --	STOP TIMER                                       --
   -----------------------------------------------------------
   text_io. put_line (long' image (timer. elapsed));

end main;



--	Let's go for the bodies

with global_def, pack_2;
use global_def;
with text_io; use text_io;
package body pack_1 is

	bool_glob:		boolean;
	char_glob_1,
	char_glob_2 :		character;
	array_glob_1:		array_1_dim_integer;
	array_glob_2:		array_2_dim_integer;
	pointer_glob,
	pointer_glob_next:	record_pointer;

	procedure proc_4;
	procedure proc_5;

	procedure proc_0 is

	   int_loc_1,
	   int_loc_2,
	   int_loc_3:		one_to_fifty;

	   char_loc:		character;
	   enum_loc:		enumeration;
	   string_loc_1,
	   string_loc_2:	string_30;

	begin
	--	initialisations

	   pack_1. pointer_glob_next := new global_def. record_type (ident_1);
	   pack_1. pointer_glob      := new global_def. record_type (ident_1);

	   pack_1. pointer_glob. all := global_def. record_type '(
					discr		=> ident_1,
					pointer_comp	=> pack_1.
						pointer_glob_next,
					enum_comp	=> ident_3,
					int_comp	=> 40,
					string_comp	=>
						"dhrystone program, some string"
				       );

	   string_loc_1 := "dhrystone program, 1 st string";

	proc_5;
	proc_4;

	-- char_glob_1 = 'A', char_glob_2 = 'b', bool_glob = false;

	int_loc_1	:= 2;
	int_loc_2	:= 3;

	string_loc_2	:= "dhrystone program, 2 nd string";
	enum_loc	:= ident_2;
	bool_glob	:= not pack_2. func_2 (string_loc_1, string_loc_2);
	-- bool_glob = true

	while int_loc_1 < int_loc_2 loop	-- loops once
	   int_loc_3 := 5 * int_loc_1 - int_loc_2;
	   -- int_loc_3 = 7
	   pack_2.proc_7 (int_loc_1, int_loc_2, int_loc_3);
	   -- int_loc_3 = 7
	   int_loc_1 := int_loc_1 + 1;
	end loop;

	-- int_loc_1 = 3;

	pack_2. proc_8 (array_glob_1, array_glob_2, int_loc_1, int_loc_3);

	-- int_glob  = 5;

	proc_1 (pointer_glob);
	for char_index in 'A' .. char_glob_2 loop	-- loops twice
	   if enum_loc = pack_2. func_1 (char_index, 'C')
	   then	-- not executed
	        pack_2. proc_6 (ident_1, enum_loc);
	   end if;
	end loop;

	-- enum_loc = ident_1
	-- int_loc_1 = 3, int_loc_2 = 3, int_loc_3 = 7

	int_loc_3	:= int_loc_2 * int_loc_1;
	int_loc_2	:= int_loc_3 / int_loc_1;
	int_loc_2	:= 7 * (int_loc_3 - int_loc_2) - int_loc_1;

	proc_2 (int_loc_1);

   end proc_0;

   procedure proc_1 (pointer_par_in:	in record_pointer) is	-- once

	subtype temp	is global_def. record_type (ident_1);
	next_record	: temp
			     renames pointer_par_in. pointer_comp. all;

   begin
	next_record	:= pointer_glob. all;
	pointer_par_in. int_comp := 5;

	next_record. int_comp :=



			        pointer_par_in. int_comp;
	next_record. pointer_comp := pointer_par_in. pointer_comp;
	proc_3 (next_record. pointer_comp);
	-- next_record. pointer_comp = pointer_glob. pointer_comp = pointer_glob_next
	if next_record. discr = ident_1
	then		-- executed
	   next_record. int_comp	:= 6;
	   pack_2. proc_6 (pointer_par_in. enum_comp, next_record. enum_comp);
	   next_record. pointer_comp	:= pointer_glob. pointer_comp;
	   pack_2. proc_7 (next_record. int_comp, 10, next_record. int_comp);
	else
		        -- not executed
	   pointer_par_in. all := next_record;
	end if;
   end proc_1;

   procedure proc_2 (int_par_in_out:	in out one_to_fifty)

   is			-- executed once
			-- in_par_in_out = 3, becomes 7
	int_loc		: one_to_fifty;
	enum_loc:	enumeration;
   begin
	int_loc		:= int_par_in_out + 10;
	loop		-- executed once
	   if char_glob_1 = 'A'
	   then		-- executed
	      int_loc	:= int_loc - 1;
	      int_par_in_out := int_loc - int_glob;
	      enum_loc	:= ident_1;
	   end if;
	   exit when enum_loc = ident_1;	-- true;
	end loop;
   end proc_2;

   procedure proc_3 (pointer_par_out	: out record_pointer)
   is		-- executed once
		-- pointer_par_out becomes pointer_glob
   begin
	if pointer_glob /= null
	then	-- executed
	   pointer_par_out	:= pointer_glob. pointer_comp;
	else	-- not executed
	   int_glob		:= 100;
	end if;

	pack_2. proc_7 (10, int_glob, pointer_glob. int_comp);
   end proc_3;

   procedure proc_4		-- without parameters
   is
	bool_loc : boolean;
   begin
	bool_loc := char_glob_1 = 'A';
	bool_loc := bool_loc or bool_glob;
	char_glob_2 := 'B';
   end proc_4;

   procedure proc_5		-- without parameters
   is
	-- executed once
   begin
	char_glob_1	:= 'A';
	bool_glob	:= false;
   end proc_5;

   end pack_1;

   package body pack_2 is

   -------------------------------------------------------

   function func_3 (enum_par_in:	in enumeration) return boolean;

   procedure proc_6 (enum_par_in:	in enumeration;
		     enum_par_out:	out enumeration)
   is
		-- executed once
		-- enum_par_in = ident_3, enum_par_out becomes ident_2
   begin
	enum_par_out	:= enum_par_in;
	if not func_3 (enum_par_in)
	then	-- not executed
	   enum_par_out := ident_4;
	end if;

	case enum_par_in is
	   when ident_1	=>	enum_par_out	:= ident_1;
	   when ident_2 =>	if pack_1. int_glob > 100
		                then enum_par_out := ident_1;
				else enum_par_out := ident_4;
				end if;
	   when ident_3 =>	enum_par_out	:= ident_2;	-- executed
	   when ident_4	=>	null;
	   when ident_5	=>	enum_par_out	:= ident_3;
	end case;
   end proc_6;

   procedure proc_7 (int_par_in_1,
	             int_par_in_2	: in one_to_fifty;
		     int_par_out	: out one_to_fifty)
   is
		-- executed three times
   		-- first call:	int_par_in_1 = 2, int_par_in_2 = 3
		--	        int_par_out becomes 7
		-- second call:	int_par_in_1 = 6, int_par_in_2 = 10
		--	        int_par_out becomes 18
		-- third call:	int_par_in_1 = 10, int_par_in_2 = 5
		--		int_par_out becomes 17

	int_loc	: one_to_fifty;
   begin
	int_loc	:= int_par_in_1 + 2;
	int_par_out := int_par_in_2 + int_loc;
   end proc_7;

   procedure proc_8 (array_par_in_out_1	: in out array_1_dim_integer;
		     array_par_in_out_2	: in out array_2_dim_integer;
		     int_par_in_1,
		     int_par_in_2	: in integer)
   is
		-- executed once
		-- int_par_in_1 = 3
		-- int_par_in_2 = 7
	int_loc	: one_to_fifty;
   begin
	int_loc		:= int_par_in_1 + 5;
	array_par_in_out_1 (int_loc) := int_par_in_2;
	array_par_in_out_1 (int_loc + 1) :=
			       array_par_in_out_1 (int_loc);

	array_par_in_out_1 (int_loc + 30) := int_loc;

	for int_index in int_loc .. int_loc + 1 loop
		-- loop body executed twice
	   array_par_in_out_2 (int_loc, int_index) := int_loc;
	end loop;

	array_par_in_out_2 (int_loc, int_loc - 1) :=
			array_par_in_out_2 (int_loc, int_loc - 1) + 1;
	array_par_in_out_2 (int_loc + 20, int_loc) :=
			array_par_in_out_1 (int_loc);
	pack_1. int_glob := 5;
   end proc_8;

   function func_1 (char_par_in_1,
		    char_par_in_2	: in capital_letter)
				return enumeration
   is
		-- executed three times
		-- returns each time ident_1
		-- first call:	char_par_in_1 = 'H'
		--		char_par_in_2 = 'R'
		-- second call:	char_par_in_1 = 'A'
		--		char_par_in_2 = 'C'
		-- third call:	char_par_in_1 = 'B'
		--		char_par_in_2 = 'C'
	char_loc_1,
	char_loc_2	: capital_letter;
   begin
	char_loc_1	:= char_par_in_1;
	char_loc_2	:= char_loc_1;
	if char_loc_2 /= char_par_in_2
	then
		-- executesd
		return ident_1;
	else	-- not executed
		return ident_2;
	end if;
   end func_1;

   function func_2 (string_par_in_1,
		    string_par_in_2	: string_30)
				return boolean

   is
		-- executed once, return false
		-- string_par_in_1 = "dhrystone, 1'st string"
		-- string_par_in_2 = "dhrystone, 2'nd string"
	int_loc	: one_to_thirty;

	char_loc	: capital_letter;
   begin
	int_loc		:= 2;
	while int_loc <= 2 loop		-- executed once
	   if func_1 (string_par_in_1 (int_loc),
		      string_par_in_2 (int_loc + 1)) = ident_1
	   then
		-- executed
		char_loc := 'A';
		int_loc  := int_loc + 1;
	   end if;
	end loop;

	if char_loc >= 'W' and char_loc < 'Z'
	then
		-- not executes
		int_loc	:= 7;
	end if;

	if char_loc = 'X'
	then
		-- not executed
		return true;
	else	-- executed
		if string_par_in_1 > string_par_in_2
		then
			-- not executed
			int_loc := int_loc + 7;
			return true;
		else	-- executed
			return false;
		end if;
	end if;
   end func_2;

   function func_3 (enum_par_in		: in enumeration)
				return boolean
   is
		-- executed once, returns true
		-- enum_par_in = ident_3
	enum_loc : enumeration;
   begin
	enum_loc := enum_par_in;
	if enum_loc = ident_3
	then
		-- executed
		return true;
	end if;
   end func_3;

 end pack_2;
--------------------------------------------------------------------
--------------------------------------------------------------------

procedure primes is		-- the main program
   task feeder; 		-- task to feed the pipe with values
   type checker;		-- task template

   type checker_ptr is access checker;
   task type checker is
      entry who_am_i (my_prime:		in positive);
      entry check_it (value_to_check:	in positive);
   end checker;

   procedure make_new_checker (a_prime_number:	positive;
                               new_checker   :	out checker_ptr);
      -- this procedure provides the ability to create new tasks
   front	: checker_ptr;
   task body feeder is separate;
   task body checker is separate;

   procedure make_new_checker (a_prime_number:	positive;
                               new_checker   :	out checker_ptr) is separate;

begin
   null;
end;

with text_io;
separate (primes)
procedure make_new_checker (a_prime_number:	in positive;
                            new_checker:	out checker_ptr) is
   result	: checker_ptr;
begin
   begin
      result := new checker;

   exception
      when storage_error =>
           text_io. put_line (" Not enough space to make new task ");
           raise;
   end;

   result. who_am_i (a_prime_number);

   -- allow task to be used in pipe

   new_checker := result;

   -- display the prime number

   text_io. put_line (integer' image (a_prime_number));
end make_new_checker;


with text_io;
with integer_io;
separate (primes)
task body feeder is
   upper_limit	: positive;

   package int_io is new integer_io (integer);

begin
   text_io. put ("Upper limit for primes? ");
   int_io. get (upper_limit);

   -- generate the first prime

   make_new_checker (2, front);

   -- feed the pipe

   for counter in 3 .. upper_limit
   loop
      front. check_it (counter);
   end loop;
end feeder;

separate (primes)
task body checker is
   my_prime,
   value_to_check	: positive;
   next_checker		: checker_ptr;
   prime		: boolean;
begin
   accept who_am_i (my_prime:	in positive) do
      checker. my_prime := my_prime;
   end who_am_i;

   loop
      select
         accept check_it (value_to_check:	positive) do
            checker. value_to_check := value_to_check;
         end check_it;
      or
         terminate;
      end select;

      prime := value_to_check mod my_prime /= 0;

      if prime then
         if next_checker /= null then
            -- it's not divisible, pass the value on
            next_checker. check_it (value_to_check);
         else
            -- it really is a prime
            make_new_checker (value_to_check, next_checker);
         end if;
      end if;
   end loop;
end checker;

-----------------------------------------------------------------
-----------------------------------------------------------------

with text_io; use text_io;
with calendar; use calendar;
with timer; use timer;
procedure queens is
   number_of_queens:	constant := 6;

   count	  	: integer := 0;
   tim:			timer.  period;

begin
   declare
      low_diag		: constant := 1 - number_of_queens;

      type config_array is array (integer range <>) of boolean;
      type col_array    is array (integer range <>) of integer;
      type configuration is
      record
         row	: config_array (1 .. number_of_queens) := (others => true);
	 r_diag	: config_array (2 .. (2 * number_of_queens)) :=
                                                         (others => true);
         diag	: config_array (low_diag .. number_of_queens - 1) :=
	                                                 (others => true);
--	 col	: col_array (1 .. number_of_queens) := (others => null);
	 col	: col_array (1 .. number_of_queens) := (others => 0);
     end record;

     task IO_CONTROL is
        entry START;
        entry STOP;
     end IO_CONTROL;

     task type node is
        entry start (column: integer; grid: configuration; caller: integer);
     end node;

     type a_of_t is array (1 .. 1) of node; -- necessary because 'new node'
                                            -- is not allowed in body node

     type a_t    is access a_of_t;

     first_level  : a_t;
     lay_out      : configuration;

     task body io_control is
     begin
        loop
           select
              accept start;
		put ("lock on IO acquired");
		new_line;
              accept stop;
		put ("lock on IO returned");
		new_line;
           or
              terminate;
           end select;
        end loop;
     end io_control;

     task body node is

        board		: configuration;
        col		: integer;
        row		: integer := 0;
        node_ptr	: a_t;
        safe		: boolean;
        local_count	: integer;
	lc		: integer;
     begin  -- the task T

        count := count + 1;
	local_count := count;

        accept start (column: integer; grid: configuration; caller: integer) do
           col   := column;
           board := grid;
	   lc	 := caller;
        end start;

--      put ("Zojuist een task NODE gestart ");
--	put (integer 'image (local_count));
--	put (" gestart door ");
--	put (integer' image (lc));
--	new_line;

        while row < number_of_queens loop   -- for each row in column

--	   put ("In task "); put (integer' image (local_count));
--	   put (" excercising row ");
--         put (integer' image (row));
--         new_line;

           row := row + 1;
           safe := board . row (row)
                and board. r_diag (col + row)
                and board. diag   (col - row);  -- find safe squares

           if safe then
              board. col (col) := row;          -- place queen
              if col = number_of_queens then
                 io_control. start;
                 put ("Solution, row numbers in column order: ");
	         put ("Found by task number ");
		 put (integer' image (local_count));
		 new_line;
                 for i in 1 .. number_of_queens loop
                     put (integer' image (board. col (i)));
                     if i /= number_of_queens then
                        put (", ");
                     end if;
                 end loop;
                 new_line;

                 io_control. stop;
              else
                 board. row (row)		:= false;
                 board. r_diag (col + row)	:= false;
                 board. diag (col - row)	:= false;

	         node_ptr			:= new a_of_t;
                 node_ptr. all (1). start (col + 1, board, local_count);

                 board. row (row)		:= true;
                 board. r_diag (col + row)	:= true;
	         board. diag (col - row)	:= true;
              end if;
           end if;
        end loop;
   -- put ("task "); put (integer' image (local_count));
   -- put ("is terminating");
   -- new_line;
     end node;

     begin
        timer. start_clock;

        first_level := new a_of_t;
        first_level. all (1). start (1, lay_out, 0);
     end;   -- do not proceed until all work is done

     put ("The total number of tasks created for this solution is: ");
     put (integer' image (count));
     new_line;

     put ("Execution time for solution (msecs): ");
     put (long' image (timer. elapsed));
     new_line;
end queens;
----------------------------------------------------------------
----------------------------------------------------------------


with text_io; use text_io;
with calendar; use calendar;
with timer; use timer;
procedure queens0 is
   number_of_queens:	constant := 6;

   count	  	: integer := 0;
   tim:			timer.  period;

begin
   declare
      low_diag		: constant := 1 - number_of_queens;

      type config_array is array (integer range <>) of boolean;
      type col_array    is array (integer range <>) of integer;
      row	: config_array (1 .. number_of_queens) := (others => true);
      r_diag	: config_array (2 .. (2 * number_of_queens)) :=
                                                         (others => true);
      diag	: config_array (low_diag .. number_of_queens - 1) :=
	                                                 (others => true);
      col	: col_array (1 .. number_of_queens) := (others => 0);

     procedure try (i: integer) is
        safe : boolean;
        j    : integer := 0;
     begin
        while j < number_of_queens
        loop
           j := j + 1;
           safe := row (j) and
                   r_diag (i + j) and
                   diag   (i - j);

           if safe
           then
              col (i)	:= j;
              row (j)	:= false;
              r_diag (i + j) := false;
              diag (i - j)   := false;

              if i < number_of_queens
              then
                 try (i + 1);
                 row (j)	:= true;
                 r_diag (i + j) := true;
                 diag (i - j)   := true;
              else
                 put ("Solution follows as row numbers in column order: ");
                 for k in 1 .. number_of_queens
                 loop
                    put (integer' image (col (k)));
                    if k < number_of_queens
                    then
                       put (", ");
                    end if;
                 end loop;
                 new_line;

                 row (j)	:= true;
                 r_diag (i + j) := true;
                 diag (i - j)   := true;
              end if;
           end if;
        end loop;
     end try;
   begin
     timer. start_clock;
     try (1);
     put ("Execution time for solution (msecs): ");
     put (long' image (timer. elapsed));
     new_line;
   end;
end queens;
-----------------------------------------------------------------
-----------------------------------------------------------------


with text_io; use text_io;
with calendar; use calendar;
with timer; use timer;
procedure queens2 is
   number_of_queens:	constant := 6;

   count	  	: integer := 0;
   tim:			timer.  period;

begin
   declare
      low_diag		: constant := 1 - number_of_queens;

      type config_array is array (integer range <>) of boolean;
      type col_array    is array (integer range <>) of integer;
      type configuration is
      record
         row	: config_array (1 .. number_of_queens) := (others => true);
	 r_diag	: config_array (2 .. (2 * number_of_queens)) :=
                                                         (others => true);
         diag	: config_array (low_diag .. number_of_queens - 1) :=
	                                                 (others => true);
--	 col	: col_array (1 .. number_of_queens) := (others => null);
	 col	: col_array (1 .. number_of_queens) := (others => 0);
     end record;

     type ord_pair is
     record
        row	: integer;
        col	: integer;
     end record;

     task IO_CONTROL is
        entry START;
        entry STOP;
     end IO_CONTROL;

     task type square is
        entry branch (board: configuration; position: ord_pair);
     end square;

     type a_square    is access square;

     type task_array is array (1 .. number_of_queens, 1 .. number_of_queens)
                        of a_square;

     square_array	: task_array;
     empty_config	: configuration;
     first_config	: configuration;
     first_position	: ord_pair;

     task body io_control is
     begin
        loop
           select
              accept start;
		put ("lock on IO acquired");
		new_line;
              accept stop;
		put ("lock on IO returned");
		new_line;
          or
              terminate;
           end select;
        end loop;
     end io_control;

     task body square is

        lay_out		: configuration;
        pos		: ord_pair;
        new_board	: configuration;
        new_position	: ord_pair;

     begin

        loop
           select
 
              accept branch (board: configuration; position : ord_pair) do
                 lay_out := board;
                 pos     := position;
              end branch;

--            stats (pos. row, pos. col) := true;

              if pos. col = number_of_queens
              then
                 io_control. start;

                 put ("Solution, row numbers in column order: ");
                 for j in 1 .. number_of_queens
                 loop
	          declare
                     k, l : integer;
	          begin
                    put (integer' image (j)); put ("****");
                    put (integer' image (lay_out. col (j)));
                    if j /= number_of_queens
                    then
                       put (", ");
                    end if;
	          end;
                 end loop;

                 new_line;
                 io_control. stop;
              else
                 for i in 1 .. number_of_queens
                 loop
                    new_board := lay_out;
                    if new_board. row (i)
                       and new_board. r_diag (i + pos. col + 1)
                       and new_board. diag   (i - (pos. col + 1))
                    then
                       new_board. col (pos. col + 1)	:= i;
                       new_board. row (i)		:= false;
                       new_board. r_diag
                                   (i + pos. col + 1)	:= false;
                       new_board. diag
                                  (i - (pos. col + 1))	:= false;
                       new_position. row		:= i;
                       new_position. col		:= pos. col + 1;

                       square_array (new_position. row, new_position. col) .
                                    branch (new_board, new_position);
                    end if;
                 end loop;
              end if;

             or
               terminate;
           end select;
        end loop;
     end square;



     begin
        timer. start_clock;

        for i in 1 .. number_of_queens
        loop
           for j in 1 .. number_of_queens
           loop
              square_array (i, j) := new square;
           end loop;
        end loop;

        for i in 1 .. number_of_queens
        loop
           first_config		:= empty_config;
           first_config. col (1):= i;
           first_config. row (i):= false;
           first_config. r_diag (i + 1) := false;
           first_config. diag   (i - 1) := false;
           first_position. row	:= i;
           first_position. col	:= 1;

           square_array (i, 1). branch (first_config, first_position);
        end loop;

     end;   -- do not proceed until all work is done


     put ("Execution time for solution (msecs): ");
     put (long' image (timer. elapsed));
     new_line;
end queens2;
--------------------------------------------------------------------
--------------------------------------------------------------------


with math;
with text_io; use text_io;
package prime_numbers is
   function number_of_primes (max_limit:	in positive) return natural;
end prime_numbers;

package body prime_numbers is
   function number_of_primes (max_limit:	in positive) return natural is
      type number_type is (prime, not_prime);
      type number_array is array (positive range <>) of number_type;
      subtype prime_range is natural range 0 .. max_limit;
      -- note that all numbers are assumed to be prime
      positive_number : number_array (2 .. max_limit) := (others => prime);
      number_primes   : prime_range := 0;

      task type slave_task is
         entry start (prime_number : in positive);
      end slave_task;

      task body slave_task is
         index,
         increment	: positive;
      begin
         accept start (prime_number: in positive) do
            increment := prime_number;
            index     := 2 * prime_number;

            -- mark off the first multiple before erasthosteness continue
            positive_number (index) := not_prime;
         end start;

         -- now mark off all remaining multiples of the prime number
         while index <= max_limit loop
            index := index + increment;
            positive_number (index) := not_prime;
         end loop;
      end slave_task;

      task erasthosteness is
         entry get_primes (number_found : out prime_range);
      end erasthosteness;

      task body erasthosteness is
         type slave_pointer is access slave_task;
         slave		: slave_pointer;
         sqrt_max_limit	: positive range 1 .. max_limit;
         prime_counter	: prime_range := 0;
      begin
--         sqrt_max_limit := integer (math. sqrt (float (max_limit))) - 0.5;
	 sqrt_max_limit := max_limit / 2;
         for loop_index in 2 .. max_limit
         loop
            if positive_number (loop_index) = prime
            then
               prime_counter := prime_counter + 1;
               -- if required the prime number could be printed
               -- or stored in an output array
               put ("Prime: ");
	       put (integer' image (loop_index));
               new_line;
	       if loop_index <= sqrt_max_limit
               then
                  slave		:= new slave_task;
                  slave. start (loop_index);
               end if;
            end if;
         end loop;
         accept get_primes (number_found: out prime_range) do
            number_found := prime_counter;
         end get_primes;
      end erasthosteness;

   begin
      erasthosteness . get_primes (number_primes);
      return number_primes;
   end number_of_primes;
end prime_numbers;
---------------------------------------------------------------
---------------------------------------------------------------



with text_io; use text_io;
with integer_io;
with prime_numbers;

procedure test_primes is
   max_number		: positive;
   package number_io is new integer_io (positive);

begin
   new_line;
   put_line ("This program counts prime numbers up to a given number");
   new_line;

   getinput:
      loop
         begin
            put_line ("Enter maximum limit for finding primes");
            number_io. get (max_number);
            exit getinput;
         exception
            when constraint_error | data_error =>
               put_line ("Primes are positive, reenter the limit");
               new_line;
         end;
      end loop get_input;

   new_line;
   put_line ("maximum number selected = " & integer' image (max_number));
   put_line ("number of primes found = " & 
                integer' image (prime_numbers. number_of_primes (max_number)));
end test_primes;

---------------------------------------------------------------------
---------------------------------------------------------------------


--
-- **********************************************************
-- * Ada PTS timer module                                   *
-- * avoids problems with inaccurate clocks                 *
-- **********************************************************
with text_io;
package timer is
   timer_inaccurate:	exception;
   subtype period	is long;
   MSTICK:		constant := 20;	-- number of msecs per tick
   procedure Start_clock;
   function Elapsed return period;
   function resolution return period;
end timer;

package body timer is
   type proc_time_buffer is record
      proc_user_time :		long;
      proc_system_time:		long;
      child_user_time :		long;
      child_system_time:	long;
   end record;

   -- borrowed from UNIX:
   procedure $times (t: in out proc_time_buffer);
   init:	boolean := false;
   tim :	proc_time_buffer;
   start_time:	long;
   procedure start_clock is
   begin
      $times (tim);
      start_time := tim. proc_user_time;
      init := true;
   end;

   function elapsed return period is
   begin
      $times (tim);
      return (tim. proc_user_time - start_time) * MSTICK;
   end;

   function resolution return period is
   begin
      return 50;
   end;
end;

-----------------------------------------------------------------
-----------------------------------------------------------------


with text_io; use text_io;
with timer;

--	whet. ada
--
--	Ada (DAS) version of Whetstone NBenchmark program
--
--	DAS COMPILER VERSION
--
procedure whetada is

subtype i is integer;
NHZ:	constant	:= 50;	-- number of guess what ? 

function $atan (x : float) return float;
function atan (x : float) return float renames $atan;
function $cos  (x : float) return float;
function cos  (x : float) return float renames $cos;
function $sin  (x : float) return float;
function sin  (x : float) return float renames $sin;
function $sqrt (x : float) return float;
function sqrt (x : float) return float renames $sqrt;
function $exp  (x : float) return float;
function exp  (x : float) return float renames $exp;
function $log  (x : float) return float;
function log  (x : float) return float renames $log;

procedure whetstone (i, no_of_cycles: in integer;
		     stop_time : out long) is

type vector is array (integer range <>) of float;

x1, x2, x3, x4, x, y, z, t, t1, t2 : float;
e1				: vector (1 .. 4);
j, k, l, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11 : integer;

procedure pa (e : in out vector) is
--	tests compuations wit an array as parameter

	j : integer;

	begin

	for j in 1 .. 6 loop
	   e1 (1) := (e1 (1) + e1 (2) + e1 (3) - e1 (4)) * t;
	   e1 (2) := (e1 (1) + e1 (2) - e1 (3) + e1 (4)) * t;
	   e1 (3) := (e1 (1) - e1 (2) + e1 (3) + e1 (4)) * t;
	   e1 (4) := (- e1 (1) + e1 (2) + e1 (3) - e1 (4)) / t;
	end loop;
end pa;

procedure p0 is
--	tests compuations wit no parameters

	begin
	   e1 (j) := e1 (k);
	   e1 (k) := e1 (l);
	   e1 (l) := e1 (j);

end p0;

procedure p3 (x, y : in out float; z : out float) is

	begin
	   x := t * (x + y);
	   y := t * (x + y);
	   z := (x + y) / t2;
end p3;

--	a main body of whetstone

	begin
	   --	set constants

	   t	:= 0.499975;
	   t1	:= 0.50025;
	   t2	:= 2.0;

	--	compute the execution frequency for the benchmark
	--	modules
	--
	   n1	:= 0;
	   n2	:= 12 * i;
	   n3	:= 14 * i;
	   n4	:= 345 * i;
	   n5	:= 0;	-- module 5 not executed

	   n6	:= 210 * i;
	   n7	:= 32 * i;
	   n8	:= 899 * i;
	   n9	:= 616 * i;
	   n10	:= 0;	-- module 10 not executed
	   n11	:= 93 * i;

--
	   timer. start_clock;		-- start the clock
--

	   cycle_loop:

	   for cycle_no in 1 .. no_of_cycles loop
	      --	module 1: compuations with simple identifiers.

	      x1	:= 1.0;
	      x2	:= -1.0;
	      x3	:= -1.0;
	      x4	:= -1.0;

	      for i in 1 .. n1 loop
	         x1 := (x1 + x2 + x3 - x4) * t;
	         x2 := (x1 + x2 - x3 + x4) * t;
	         x3 := (x1 - x2 + x3 + x4) * t;
	         x4 := (-x1 + x2 + x3 + x4) * t;
	      end loop;

	      -- end module 1


--	MODULE 2:	compuations with array elements

	      e1 (1)	:= 1.0;
	      e1 (2)	:= -1.0;
	      e1 (3)	:= -1.0;
	      e1 (4)	:= -1.0;

	      for i in 1 .. n2 loop
	         e1 (1) := (e1 (1) + e1 (2) + e1 (3) - e1 (4)) * t;
	         e1 (1) := (e1 (1) + e1 (2) - e1 (3) + e1 (4)) * t;
	         e1 (1) := (e1 (1) - e1 (2) + e1 (3) - e1 (4)) * t;
	         e1 (1) := (-e1 (1) + e1 (2) + e1 (3) - e1 (4)) * t;
	      end loop;

	--	END MODULE 2

	--	MODULE 3: passing array as parameter

	      for i in 1 .. n3 loop
	         pa (e1);
	      end loop;

	--	END MODULE 3
	--
	--	MODULE 4 : performing conditional jumps

	--
	      j := 1;
	      for i in 1 .. n4 loop
	         if j = 1 then
	            j := 2;
	         else
	            j := 3;
	         end if;

	         if j > 2 then
	            j := 0;
	         else
	            j := 1;
	         end if;

	         if j < 1 then
	            j := 1;
	         else
	            j := 0;
	         end if;
	      end loop;

	--	END MODULE 4
	--
	--	MODULE 5 : OMITTED
	--
	--	MODULE 6: performing integer arithmetic
	--
	      j := 1;
	      k := 2;
	      l := 3;
	      for i in 1 .. n6 loop
	         j := j * (k - j) * (l - k);
	         k := l * k - (l - j) * k;
	         l := (l - k) * (k + j);
	         e1 (l - 1) := float (j + k + l);
	         e1 (k - 1) := float (j * k * l);
	      end loop;

	--	END MODULE 6
	--
	--	MODULE 7;
	--	MODULE 7 : performing compuations using trigonometric
	--	           functions

	      x := 0.5;
	      y := 0.5;
	      for i in 1 .. n7 loop
	         x := t * atan (t2 * sin (x) * cos (x) / (cos (x + y) + cos (x + y) - 1.0));
	         y := t * atan (t2 * sin (y) * cos (y) / (cos (x + y) + cos (x + y) - 1.0));
	      end loop;

	--	END MODULE 7
	--
	--	MODULE 8 : procedure calls with simple identifiers as parameters
	      x	:= 1.0;
	      y	:= 1.0;
	      z := 1.0;

	      for i in 1 .. n8 loop
	         p3 (x, y, z);
	      end loop;

	--	END OF MODULE 8
	--
	--	MODULE 9: array references and procedure calls with no parameters
	--
	      j		:= 1;
	      k		:= 2;
	      l		:= 3;

	      e1 (1)	:= 1.0;
	      e1 (2)	:= 2.0;
	      e1 (3)	:= 3.0;

	      for i in 1 .. n9 loop
	         p0;
	      end loop;

	--	END OF MODULE 9
	--
	--	MODULE 10 : integer arithmetic
	--
	      j := 2;
	      k := 3;
	      for i in 1 .. n10 loop
	         j := j + k;
	         k := j + k;
	         j := k - j;
	         k := k - j - j;
	      end loop;
	--	END OF MODULE 10
	--
	--	MODULE 11 : performing compuations using standard mathematical functions
	--
	      x		:= 0.75;
	      for i in 1 .. n11 loop
	         x := sqrt (exp (log (x) / t1));
	      end loop;
	--	END OF MODULE 11

	end loop CYCLE_LOOP;

	--
	stop_time := timer. elapsed;
end whetstone;

procedure compute_whetstone_kips is
--
--	variables used to control execution of benchmark and to
--	compute the whetstone rating

	no_of_runs	: integer;	-- number of times the benchmark is executed
	no_of_cycles	: integer;	-- number of times the group of benchmarks
					-- modules is executed
	i		: integer;	-- factor weighting number of times each module loops
					-- a value of ten gives a total weight for modules
					-- of appr one million whetstone instructions
	elapsed_time	: long;		-- time between start ans stoptime
	mean_time	: long;	-- average time per cycle
	rating		: long;	-- thousands of whetstone instructions per second
	mean_rating	: long;	-- average whetstone rating
	int_rating	: integer;	-- integer value of kwips


	begin
	   put_line ("Whetstone benchmark for Ada- compiler\n");

	--
	   mean_rating	:= 0;
	   mean_time	:= 0;
	   no_of_cycles := 10;
	   no_of_runs	:= 5;

	   i		:= 10;

--

	   run_loop:

	   for run_no in 1 .. no_of_runs loop
	   --
	   --  call the whetstone benchmark procedure
	   --
	      whetstone (i, no_of_cycles, elapsed_time);
	   --
	   --
	      put ("elapsed time for");
              put (integer' image (no_of_cycles));
              put (" cycles is ");
              put (long' image (elapsed_time));
              put (" milliseconds");
	      new_line;
	--
	      mean_time := mean_time + elapsed_time / long (no_of_cycles);
	--
	--   calculate the Whetstone rating based on the time for the number of
	--   cycles just executed and write
	--
	     rating := (1000000 * long (no_of_cycles))/ elapsed_time;
	--
	--   Sum Whetstone rating
	--
	   mean_rating	:=     mean_rating + rating;
	   int_rating	:=     integer (rating);
	   new_line;

	   put (" Whetstone rating ");
           put (integer' image (int_rating));
	   put (" kwips ");
	   new_line;

	--
	-- reset no_of_cycles for next run using ten cycles more
	--
	   no_of_cycles := no_of_cycles + 10;
	end loop run_loop;

	--
	-- compute the avergae time in milliseconds per cycle and write
	--
	   mean_time := mean_time / long (no_of_runs);
	   new_line;

	   put ("Average time per cycle ");
           put (long ' image (mean_time));
           put (" milli seconds ");
	   new_line;

	--
	-- calculate average whetstone rating and write
	--
	   mean_rating	:= mean_rating / long (no_of_runs);
	   put ("Average whetstone rating =");
           put (long' image (mean_rating));
	   put ("kwips ");
	   new_line;

   end compute_whetstone_kips;
--
	begin
		compute_whetstone_kips;
end whetada;

--------------------END OF DEMO's --------------------------------


