index(ps,c)
char *ps;
char  c;
{
  if (ps) {
    while (*ps && *ps!=c) ps++;
    if (*ps==0) ps=0;
  }
  return ps;
}

