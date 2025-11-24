with text_io; use text_io;
generic
   -- user supplied formal parameter that states the name
   -- of the external data base file. Its type is not
   -- generic, but the default (text) fil type of text_io
   --

   db_file:	in out file_type;

   -- user supplied private type denoting type of
   -- data base obejcts

   type elem is private;

   -- user supplied type denoting ordering used in the user
   -- user supplied formal relation function

   type kind is (<>);

   -- user suplied formal parameter givinh a relation

   with function in_order (x, y: in elem;
                           c:    in kind) return boolean;

   -- here it is assumed that the user must perform the usual
   -- file operations like open and close
   -- only the end of file operator must be supplied

   with function eof (file: file_type) return boolean;

   -- user supplied formal parameter giving a write procedure
   -- for the objects in the data base

   with procedure write (the:  in elem;
                         to:   file_type := standard_output);

   with procedure read  (the:  out elem;
                         from: file_type := standard_input);

   -- these were the parameters

package data_base is
    -- total number of objects that can be handled by the data base

   maximum_records : constant := 100;

   -- exception no_more_objects is raised when during iteration over
   -- the data base all objects are iterated over
   no_more_objects : exception;

   -- an object in the data base is characterized by its key_value
   -- this value acts as an index in an array of pointers to objects
   -- pointers are chosen to obtain a "fast" implementation of the
   -- order operation and to obtain an easy identification
   -- of a non-present element. It is used in the delete operation
   -- to nullify a data base object

   -- the key_value -1 denotes a null key, used to communicate
   -- a non valid key_value
   -- valid keys range from 0 to maximum records

   type rec_key is range -1 .. maximum_records;
   subtype valid_key is rec_key range 0 .. rec_key' last;

   type link is access elem;
   type elem_storage is array (valid_key) of link;

   null_object:  constant link := null;
   null_key   :  constant rec_key := -1;

   -- the actual data base

   data: elem_storage := (others => null_object);

   -- active_records acts as an indicator of the number of records
   -- currently in the data base
   active_records : rec_key := null_key;

   -- operations on the data base are:

   procedure load_data_base;
   procedure store_data_base;
   procedure show_data_base;
   function select_object	(key: valid_key) return elem;
   procedure delete		(key: valid_key);
   procedure insert		(element: elem);
   function get_key		(element: elem) return rec_key;
   procedure order_db		(crit:    kind);
   function first_data_object return elem;
   function next_data_object  return elem;
end data_base;

package body data_base is
   -- eerste is used to indicate the first valid key value

   eerste : rec_key := 0;

   -- iter_key is used to iterate over the database

   iter_key: rec_key := null_key;

   procedure load_data_base is
      curr_item : link;
   begin
      -- assume user opened file
      active_records := null_key;
      while not eof (db_file) loop
         curr_item := new elem;
         read (the => curr_item. all, from => db_file);
         active_records := active_records + 1;
         data (active_records) := curr_item;
      end loop;
   end load_data_base;

   procedure store_data_base is
      curr_item : link;
      -- only real items, i.e. non-null items are not stored
   begin
      for i in 0 .. active_records loop
         curr_item := data (i);
         if curr_item /= null
         then
            write (the => curr_item. all, to => db_file);
         end if;
      end loop;
   end store_data_base;

   procedure show_data_base is
      curr_item : link;
   begin
      for i in 0 .. active_records loop
         curr_item := data (i);
	 if curr_item /= null
         then
            write (the => curr_item. all, to => standard_output);
	 end if;
      end loop;
   end;

   procedure insert (element: elem) is
      new_elem : link;
   begin
      new_elem := new elem;
      new_elem. all := element;
      active_records := active_records + 1;
      data (active_records) := new_elem;
   end;

   procedure delete (key: valid_key) is
   begin
      $deallocate (data (key));	-- sets parameter to null pointer
   end;

   function select_object (key: valid_key) return elem is
   begin
      return data (key). all;
   end;

   function get_key (element: elem) return rec_key is
      curr_key : rec_key := null_key;
   begin
      while curr_key <= active_records loop
         exit when element = data (curr_key). all;
         curr_key := curr_key + 1;
      end loop;

      if curr_key > active_records
      then
         return null_key;
      else
         return curr_key;
      end if;
   end get_key;

   procedure swap (i, j: valid_key) is
      tmp : link;
   begin
      tmp := data (i);
      data (i) := data (j);
      data (j) := tmp;
   end;

   procedure order_db (crit: kind) is
      -- use a simple bubble sort to order the data base
   begin
      if active_records = null_key
      then
         return;
      end if;

      for i in eerste .. active_records - 1 loop
         for j in i + 1 .. active_records loop
            if data (i) /= null and then data (j) /= null
            then
               if not in_order (data (i). all, data (j). all, crit)
               then
                  swap (i, j);
               end if;
            end if;
         end loop;
      end loop;
   end order_db;

   function first_data_object return elem is
      item	: link;
   begin
      iter_key := null_key + 1;
      item := data (iter_key);
      if item = null
      then
         raise no_more_objects;
      else
         return item. all;
      end if;
   end;

   function next_data_object return elem is
      item: link;
   begin
      if iter_key = maximum_records
      then
         raise no_more_objects;
      else
         iter_key := iter_key + 1;
         item := data (iter_key);
         if item = null
         then
            raise no_more_objects;
         else
            return item. all;
         end if;
      end if;
   end;
end data_base;

