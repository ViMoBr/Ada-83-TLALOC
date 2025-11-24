--
--	input/output package for Ada-  compiler
--
--	j van katwijk
--	september 1987
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
	not_yet_implemented:	exception;
end io_exceptions;
