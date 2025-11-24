package pattern_making is
-- useful constants and types
EOP:      constant character :=	character' val (1);
ANY_CHAR:	constant character := '?';
BOL_CHAR:	constant character := '^';
EOL_CHAR:	constant character := '%';
SUB_CHAR:	constant character := '[';
BUS_CHAR:	constant character := ']';
CLOS_CHAR:	constant character := '*';
ESCAPE_CHAR:	constant character := '@';


type key_kind is (any_key, clos_key, eol_key, bol_key, ccl_key, char_key);
type pattern_element (pattern_key: key_kind);
type pattern is access pattern_element;
type pattern_element (pattern_key: key_kind) is record
     next: pattern;
     case pattern_key is
       when char_key           => pattern_char_value : character;
       when ccl_key | clos_key => low_val            : pattern;
       when others             => null;
     end case;
end record;

function Make_Pattern (s: string; f: boolean) return pattern;
end pattern_making;
