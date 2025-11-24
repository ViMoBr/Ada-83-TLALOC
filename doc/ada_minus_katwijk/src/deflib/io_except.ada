--
-- package io_exceptions
--
-- according to LRM
-- 
-- j van katwijk
-- september 1987
--
-- Ton Biegstraaten, abi@dutinfd
-- januari 1988
--
package io_exceptions is
	status_error:	exception;
	mode_error:	exception;
	name_error:	exception;
	use_error:	exception;
	device_error:	exception;
	end_error:	exception;
	data_error:	exception;
	layout_error:	exception;
-- make the difference between LRM and this implementation visible
-- all not implemented functions generate the next exception
	not_yet_implemented:	exception;
end io_exceptions;


