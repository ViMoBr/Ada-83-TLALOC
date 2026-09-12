procedure BUG1_AGGREGATE
is

  type PAGE_IDX			is range 0 .. 255;

  MAX_VPG				:constant PAGE_IDX	:= PAGE_IDX'LAST;
  subtype VPG_IDX			is PAGE_IDX range 0	.. MAX_VPG;
  subtype VPG_NUM			is VPG_IDX  range 1	.. MAX_VPG;

  MAX_RPG				: constant	:= 50;
  type RPG_IDX			is new INTEGER range 0 .. MAX_RPG;

  ASSOC_PAGE			: array( VPG_NUM ) of RPG_IDX		:= (others=> 0);

begin
  ASSOC_PAGE := (others=> 0);

end	BUG1_AGGREGATE;
