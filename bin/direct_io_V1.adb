					---------
package body				DIRECT_IO
is					---------

			------
  procedure		CREATE		( FILE :in out FILE_TYPE;
					  MODE :in FILE_MODE	:= INOUT_FILE;
					  NAME :in STRING		:= "";
					  FORM :in STRING		:= ""
					)
  is			-------
  begin
    null;

  end	CREATE;
	------


			----
  procedure		OPEN		( FILE : in out FILE_TYPE;
					  MODE : in FILE_MODE;
					  NAME : in STRING;
					  FORM : in STRING		:= ""
					)
  is			----
  begin
    null;

  end	OPEN;
	----


			-----
  procedure		CLOSE		( FILE :in out FILE_TYPE )
  is			-----
  begin
    null;

  end	CLOSE;
	-----


			------
  procedure		DELETE		( FILE :in out FILE_TYPE )
  is			------
  begin
    null;

  end	DELETE;
	------


			-----
  procedure		RESET		( FILE :in out FILE_TYPE; MODE :in FILE_MODE )
  is			-----
  begin
    null;

  end	RESET;
	-----


			-----
  procedure		RESET		( FILE :in out FILE_TYPE )
  is			-----
  begin
    null;

  end	RESET;
	-----


			----
  function		MODE		( FILE :in FILE_TYPE )		return FILE_MODE
  is			----
  begin
    return IN_FILE;

  end	MODE;
	-----


			----
  function		NAME		( FILE :in FILE_TYPE )		return STRING
  is			----
  begin
    return "";

  end	NAME;
	----

			----
  function		FORM		( FILE :in FILE_TYPE )		return STRING
  is			----
  begin
    return "";

  end	FORM;
	----

			-------
  function		IS_OPEN		( FILE :in FILE_TYPE )		return BOOLEAN
  is			-------
  begin
    return FALSE;

  end	IS_OPEN;
	-------


	 -- Input	and output operations


			----
  procedure		READ		( FILE :in  FILE_TYPE;
					  ITEM :out ELEMENT_TYPE;
					  FROM :in  POSITIVE_COUNT
					)
  is			----
  begin
    null;

  end	READ;
	----


			----
  procedure		READ		( FILE :in  FILE_TYPE;
					  ITEM :out ELEMENT_TYPE
					)
  is			----
  begin
    null;

  end	READ;
	----

			-----
  procedure		WRITE		( FILE :in FILE_TYPE;
					  ITEM :in ELEMENT_TYPE;
					  TO   :in POSITIVE_COUNT
					)
  is			-----
  begin
    null;

  end	WRITE;
	-----

			-----
  procedure		WRITE		( FILE :in FILE_TYPE;
					  ITEM :in ELEMENT_TYPE )
  is			-----
  begin
    null;

  end	WRITE;
	-----


			---------
  procedure		SET_INDEX		( FILE :in FILE_TYPE;  TO :in	POSITIVE_COUNT )
  is			---------
  begin
    null;

  end	SET_INDEX;
	---------


			-----
  function 		INDEX		( FILE :in FILE_TYPE )		return POSITIVE_COUNT
  is			-----
  begin
    return 1;

  end	INDEX;
	-----


			----
  function		SIZE		( FILE :in FILE_TYPE)		return COUNT
  is			----
  begin
    return 0;

  end	SIZE;
	----

			-----------
  function		END_OF_FILE	( FILE :in FILE_TYPE)		return BOOLEAN
  is			-----------
  begin
    return FALSE;

  end	END_OF_FILE;
	-----------


	---------
end	DIRECT_IO;
	---------
