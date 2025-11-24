

with math;
with text_io; use text_io;
package prime_numbers is
   function number_of_primes (max_limit:	in positive) return natural;
end prime_numbers;

package body prime_numbers is
   function number_of_primes (max_limit:	in positive) return natural is
      type number_type is (prime, not_prime);
      type number_array is array (positive range <>) of number_type;
      subtype prime_range is natural range 0 .. max_limit;
      -- note that all numbers are assumed to be prime
      positive_number : number_array (2 .. max_limit) := (others => prime);
      number_primes   : prime_range := 0;

      task type slave_task is
         entry start (prime_number : in positive);
      end slave_task;

      task body slave_task is
         index,
         increment	: positive;
      begin
         accept start (prime_number: in positive) do
            increment := prime_number;
            index     := 2 * prime_number;

            -- mark off the first multiple before erasthosteness continue
            positive_number (index) := not_prime;
         end start;

         -- now mark off all remaining multiples of the prime number
         while index <= max_limit loop
            index := index + increment;
            positive_number (index) := not_prime;
         end loop;
      end slave_task;

      task erasthosteness is
         entry get_primes (number_found : out prime_range);
      end erasthosteness;

      task body erasthosteness is
         type slave_pointer is access slave_task;
         slave		: slave_pointer;
         sqrt_max_limit	: positive range 1 .. max_limit;
         prime_counter	: prime_range := 0;
      begin
--         sqrt_max_limit := integer (math. sqrt (float (max_limit))) - 0.5;
	 sqrt_max_limit := max_limit / 2;
         for loop_index in 2 .. max_limit
         loop
            if positive_number (loop_index) = prime
            then
               prime_counter := prime_counter + 1;
               -- if required the prime number could be printed
               -- or stored in an output array
               put ("Prime: ");
	       put (integer' image (loop_index));
               new_line;
	       if loop_index <= sqrt_max_limit
               then
                  slave		:= new slave_task;
                  slave. start (loop_index);
               end if;
            end if;
         end loop;
         accept get_primes (number_found: out prime_range) do
            number_found := prime_counter;
         end get_primes;
      end erasthosteness;

   begin
      erasthosteness . get_primes (number_primes);
      return number_primes;
   end number_of_primes;
end prime_numbers;
