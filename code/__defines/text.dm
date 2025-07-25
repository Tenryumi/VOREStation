/**
 * Holds global defines for use in text input procedures
 */


/**
 * stuff like `copytext(input, length(input))` will trim the last character of the input,
 * because DM does it so it copies until the char BEFORE the `end` arg, so we need to bump `end` by 1 in these cases.
 */
#define PREVENT_CHARACTER_TRIM_LOSS(integer) (integer + 1)

/// Simply removes the < and > characters, and limits the length of the message.
#define STRIP_HTML_SIMPLE(text, limit) (GLOB.angular_brackets.Replace(copytext(text, 1, limit), ""))

/// Removes characters incompatible with file names.
#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

#define MAX_MESSAGE_CHUNKS 130

#define MAX_TGUI_INPUT (MAX_MESSAGE_CHUNKS * 1024)

#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

// Remove the + 1 at the end once byond fixes the issue. Currently MeasureText returns 1 px too less often
#define WXH_TO_HEIGHT(measurement, return_var) \
	do { \
		var/_measurement = measurement; \
		return_var = text2num(copytext(_measurement, findtextEx(_measurement, "x") + 1)) + 1; \
	} while(FALSE);
