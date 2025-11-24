/*
  d.c
  data
  19880723/wjvg
*/

#include "def.h"

char Sdyad []="pptd";
char Sfield[]="pntd";
char Sleaf []="lnts";
char Smonad[]="p0td";
char Sstruc[]="pptnn";
char Sunyst[]="p0tnn";

char Sbytes[]="N";
char Slang []="L";
char Snumb []="n";
char Sstrin[]="s";

struct sinfo ic00[]={
  {"undef"     ,0},    /*0*/
  {"icalign"   ,Snumb},
  {"ictext"    ,0},
  {"icdata"    ,0},
  {"icbss"     ,0},
  {"iclong"    ,Snumb},
  {"icword"    ,Snumb},
  {"icbyte"    ,Snumb},
  {"icbytes"   ,Sbytes},
  {"icdlabn"   ,Snumb},
  {"icdlabs"   ,Sstrin},  /*10*/
  {"icjlabn"   ,Snumb},
  {"icjlabs"   ,Snumb},
  {"icfbeg"    ,"nnns"},
  {"icfend"    ,0},
  {0           ,0},
  {"icskip"    ,Snumb},
  {"iccomm"    ,"ns"},
  {"icinit"    ,0},
  {"icswtch"   ,Snumb},
  {"icswdef"   ,Snumb},   /*20*/
  {"icswent"   ,"nn"},
  {"icswend"   ,0},
  {"iccom"     ,Sstrin},
  {"icglobl"   ,Sstrin},
  {"icjfend"   ,0},
  {"icnequ"    ,"sn"},
  {"icsequ"    ,"ss"},
  {"icvers"    ,0},
  {"icaddr"    ,Sstrin},
  {"icstring"  ,Sstrin},   /*30*/
  {0           ,0},
  {0           ,0},
  {"iclanguage",Slang},
  {"icnop"     ,0},
  {"icjsr"     ,Sstrin},
  {"icrts"     ,0},
  {"icfile"    ,Sstrin},
  {"icln"      ,Snumb},
  {"icdef"     ,Sstrin},
  {"icendef"   ,0},    /*40*/
  {"icval"     ,Snumb},
  {"ictype"    ,Snumb},
  {"icscl"     ,Snumb},
  {"ictag"     ,Sstrin},
  {"icline"    ,Snumb},
  {"icsize"    ,Snumb},
  {"icdim"     ,Sbytes},
  {"icvals"    ,0},
  {"ichex"     ,0},
  {"icfloat"   ,Sstrin},  /*50*/
  {"icdouble"  ,Sstrin}   /*51*/
};

struct sinfo ic290[]={
  {"."   ,"nq"},         /*290*/
  {"["   ,"nnnRS"},
  {"]"   ,0},
  {")"   ,Sstrin}        /*293*/
};

struct sinfo nu00[]={
  {"UNDEF"   ,0},       /*0*/
  {"error"   ,0},      
  {"name"    ,Sleaf}, 
  {"string"  ,0},      
  {"icon"    ,Sleaf},
  {"fcon"    ,"llt"},   
  {"+"       ,Sdyad},    
  {"+="      ,Sdyad},     
  {"-"       ,Sdyad},    
  {"-="      ,Sdyad},     
  {"uny_-"   ,Smonad},  /*10*/
  {"*"       ,Sdyad},    
  {"*="      ,Sdyad},     
  {"uny_*"   ,Smonad},   
  {"&"       ,Sdyad},    
  {"&="      ,Sdyad},     
  {"uny_&"   ,Smonad},      
  {"|"       ,Sdyad},    
  {"|="      ,Sdyad},     
  {"^"       ,Sdyad},    
  {"^="      ,Sdyad},  /*20*/
  {"?"       ,Sdyad},    
  {":"       ,Sdyad},    
  {"&&"      ,Sdyad},    
  {"||"      ,Sdyad},  /*24*/
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},    /*30*/
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {"goto"    ,Smonad}, /*37*/
  {0         ,0},
  {0         ,0},
  {0         ,0},    /*40*/
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},    /*50*/
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {0         ,0},
  {"cm"      ,Sdyad},  /*56*/
  {"sm"      ,0},      
  {"="       ,Sdyad},    
  {"comop"   ,Sdyad},    
  {"/"       ,Sdyad},  /*60*/
  {"/="      ,Sdyad},     
  {"%"       ,Sdyad},    
  {"%="      ,Sdyad},     
  {"<<"      ,Sdyad},    
  {"<<="     ,Sdyad},     
  {">>"      ,Sdyad},    
  {">>="     ,Sdyad},     
  {"dot"     ,0},      
  {"stref"   ,0},      
  {"call"    ,Sdyad},  /*70*/
  {0         ,0},      
  {"unycall" ,Smonad},   
  {"fortcall",0},      
  {0         ,0},      
  {0         ,0},      
  {"!"       ,Smonad},   
  {"~"       ,Smonad},   
  {"++"      ,Sdyad},   /*post*/
  {"--"      ,Sdyad},   /*post*/
  {"=="      ,Sdyad},   /*80*/
  {"!="      ,Sdyad},    
  {"<="      ,Sdyad},    
  {"<"       ,Sdyad},    
  {">="      ,Sdyad},    
  {">"       ,Sdyad},    
  {"u<="     ,Sdyad},    
  {"u<"      ,Sdyad},    
  {"u>="     ,Sdyad},    
  {"u>"      ,Sdyad},    
  {"setbit"  ,0},      /*90*/
  {"testbit" ,0},      
  {"resetbit",0},
  {0         ,0},      
  {"reg"     ,Sleaf},  
  {"oreg"    ,Sleaf},  
  {"ccodes"  ,0},      
  {"free"    ,0},      
  {"stasg"   ,Sstruc},  
  {"starg"   ,Sunyst},  
  {"stcall"  ,Sstruc},  /*100*/
  {0         ,0},      
  {"unystcal",Sunyst},  
  {"fld"     ,Sfield},   
  {"sconv"   ,Smonad},   
  {"pconv"   ,0},      
  {"pmconv"  ,0},      
  {"pvconv"  ,0},      
  {"force"   ,Smonad},   
  {"cbranch" ,Sdyad},    
  {"init"    ,Smonad},   /*110*/
  {0         ,0},      
  {0         ,0},      
  {0         ,0},      
  {0         ,0},      
  {0         ,0},      
  {0         ,0},      
  {0         ,0},      
  {0         ,0},      
  {0         ,0},      
  {"revcall" ,Sdyad},    /*120*/
  {"revstcal",Sstruc},      
  {"revcm"   ,Sdyad},      
  {"rev-"    ,Sdyad},
  {"rev/"    ,Sdyad},
  {"rev%"    ,Sdyad},
  {"rev<<"   ,Sdyad},
  {"rev>>"   ,Sdyad},
  {"reva>>"  ,Sdyad},
  {"revcbran",Sdyad}
};

/*end*/
