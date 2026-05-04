generic
  type ELEMENT_TYPE		is limited private;
  type INDEX_TYPE		is range <>;
  type ELEMENT_ARRAY	is array( INDEX_TYPE range <> ) of ELEMENT_TYPE;
  with procedure USE_ELEMENT	( ELEMENT : in out Element_Array );
	------------------
procedure Cca_Allocate_Array	( Last : INDEX_TYPE );
	------------------
