with system;
with unix;
package calendar is
   --
   -- (very) preliminary implementation of package calendar
   --

   type time is private;

   subtype year_number is integer range 1901 .. 2099;
   subtype month_number is integer range 1 .. 12;
   subtype day_number  is integer range 1 .. 31;
   subtype day_duration is long range 0 .. 86_400;

   function clock return time;

   function year	(date:	time) return year_number;
   function month	(date:	time) return month_number;
   function day		(date:	time) return day_number;
   function seconds	(date:	time) return day_duration;

   procedure split	(date:	time;
			 year:	out year_number;
			 month:	out month_number;
			 day:	out day_number;
			 seconds: out day_duration);

   function time_of	(year:	year_number;
			 month:	month_number;
			 day:	day_number;
			 seconds: day_duration := 0) return time;

   function "+"		(left:	time;
			 right:	duration) return time;
   function "+"		(left:	duration;
			 right:	time) return time;
   function "-"		(left:	time;
			 right:	duration) return time;
   function "-"		(left:	time;
			 right:	time) return duration;

   time_error:		exception;
private
   --
   -- model the unix idea of time
   --
   type time is new unix. tm;
end;

package body calendar is

   function clock return time is
      x : long;
   begin
      x := unix. $time;
      return time (unix. $gmtime (x' address). all);
   end;

   function year (date : time) return year_number is
   begin
      return year_number (date. tm_year);
   end;

   function month (date: time) return month_number is
   begin
      return month_number (date. tm_mon);
   end;

   function day (date:   time) return day_number is
   begin
      return day_number (date. tm_mday);
   end;

   function seconds (date: time) return day_duration is
   begin
      return date. tm_sec;
   end;

   procedure split  (date:	time;
		     year:	out year_number;
		     month:	out month_number;
		     day:	out day_number;
		     seconds:	out day_duration) is
   begin
      year :=		integer (date. tm_year) + 1900;
      month :=		integer (date. tm_mon);
      day  :=		integer (date. tm_mday);
      seconds :=	day_duration (date. tm_sec);
   end;

end;

      
