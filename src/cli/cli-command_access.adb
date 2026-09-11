------------------------------------------------------------------------------------------------------------------------
-- SPDX-FileCopyrightText: 2026 VINCENT MORIN, UBO
-- SPDX-License-Identifier: GPL-3.0-or-later
------------------------------------------------------------------------------------------------------------------------
--	1	2	3	4	5	6	7	8	9	0	1	2
separate ( CLI )

				--------------
package body			COMMAND_ACCESS
is				--------------


			------
  function		LOOKUP		( NAME :STRING )		return POSITIVE
  is			------
    -- Entry of NAME for the parsed verb (or common) ; NO_SUCH_NAME if none.
    I	:constant NATURAL	:= FIND_ENTRY( NAME, CURRENT_VERB );
  begin
    if  I = 0  then
      raise  NO_SUCH_NAME;
    end if;
    return  I;

  end	LOOKUP;
	------


			---------
  function		TOOL_NAME			return STRING
  is			---------
  begin
    return DEFINITION_TEXT( TOOL );

  end	TOOL_NAME;
	---------


			--------
  function		GET_VERB			return STRING
  is			--------
  begin
    if  CURRENT_VERB = 0  then
      return  "";
    end if;
    return  DEFINITION_TEXT( ENTRIES( CURRENT_VERB ).NAME );

  end	GET_VERB;
	--------


			----------
  function 		IS_PRESENT	( NAME :STRING )		return BOOLEAN
  is			----------
  begin
    return  ENTRIES( LOOKUP( NAME ) ).STATUS = PRESENT;

  end	IS_PRESENT;
	----------


			---------
  function		STATUS_OF		( QUALIFIER :STRING )		return QUALIFIER_STATUS
  is			---------
  begin
    return  ENTRIES( LOOKUP( QUALIFIER ) ).STATUS;

  end	STATUS_OF;
	---------


			-----------
  function		VALUE_COUNT	( NAME :STRING )			return NATURAL
  is			-----------
  begin
    return  ENTRIES( LOOKUP( NAME ) ).VALUES_FOUND;

  end	VALUE_COUNT;
	-----------


			---------
  function		GET_VALUE		( NAME :STRING; INDEX :POSITIVE := 1 )		return STRING
  is			---------

    I	:constant POSITIVE	:= LOOKUP( NAME );
    N	: NATURAL		:= 0;

  begin
    if  INDEX > ENTRIES( I ).VALUES_FOUND  then
      raise  NO_VALUE;
    end if;

    for  V in 1 .. VALUE_TOP  loop
      if  VALUES( V ).OWNER = I  then
	N := N + 1;
	if  N = INDEX  then
	  return  COMMAND_TEXT( VALUES( V ).TEXT );
	end if;
      end if;
    end loop;
    raise  NO_VALUE;

  end	GET_VALUE;
	---------


	--------------
end	COMMAND_ACCESS;
	--------------


--	1	2	3	4	5	6	7	8	9	0	1	2
------------------------------------------------------------------------------------------------------------------------
