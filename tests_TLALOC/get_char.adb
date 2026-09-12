with TEXT_IO; use TEXT_IO;
procedure GET_CHAR is
  C	: CHARACTER;
begin
  PUT( "Tapez un caractere : " );
  GET( C );
  PUT( '<' ); PUT( C ); PUT( '>' );
  NEW_LINE;
end GET_CHAR;
