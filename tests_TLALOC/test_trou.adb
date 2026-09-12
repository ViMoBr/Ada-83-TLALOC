procedure TEST_TROU
is
  B	:BOOLEAN;

  task T is
  end T;

  task body T
  is
  begin
  null;
  end;

begin
  B := T'TERMINATED;
end TEST_TROU;
