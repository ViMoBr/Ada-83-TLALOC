procedure TEST_ADDRESS
is

  CIBLE_1	:INTEGER;

  ALIAS_1	:INTEGER;	for ALIAS_1 use at CIBLE_1'ADDRESS;

  TQ	: array( 1..4 ) of LONG_INTEGER;
  TD	: array( 1..2 ) of INTEGER;	for TD use at TQ'ADDRESS;

  procedure SYSTEM_CALL	( P :INTEGER );	for SYSTEM_CALL use at 16#200_0000#;

begin
  null;
end	TEST_ADDRESS;
