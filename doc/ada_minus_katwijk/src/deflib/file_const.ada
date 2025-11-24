--
-- package file_constants
--
-- Ton Biegstraaten, abi@dutinfd
-- januari, 1988
--
package file_constants is
--
    FULLNAMESIZE    :   constant := 100;
    FORMLENGTH      :   constant := 10;
    UNAMESIZE       :   constant := 20;
    
    subtype formstring is string (1 .. FORMLENGTH);
    subtype filename is string (1 .. FULLNAMESIZE);
end;
