separate (IDL.SEM_PHASE)
    --|----------------------------------------------------------------------------------------------
    --| DEF_WALK
    --|----------------------------------------------------------------------------------------------
package body DEF_WALK is
  use DEF_UTIL;
  use VIS_UTIL;
  use MAKE_NOD;
  use NOD_WALK;
  use EXP_TYPE, EXPRESO;
  use REQ_UTIL;
  use SET_UTIL;
  use GEN_SUBS;

  function COPY_COMP_LIST_IDS (COMP_LIST : TREE; H : H_TYPE) return TREE;
  function C
