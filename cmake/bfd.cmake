INCLUDE (CheckIncludeFile)
INCLUDE (CheckCSourceCompiles)

CHECK_INCLUDE_FILE (bfd.h HAVE_BFD)

IF (HAVE_BFD)
	FIND_LIBRARY (LIBBFD_TMP bfd)

	IF (NOT LIBBFD)
		MESSAGE (STATUS "No useable bfd-lib found, disabling support")
	ELSE (NOT LIBBFD)
		FOREACH (
			CMAKE_REQUIRED_LIBRARIES "" "${LIBBFD_TMP}" "${LIBBFD_TMP};iberty" "${LIBBFD_TMP};dl" "${LIBBFD};iberty;dl" "${LIBBFD_TMP};${LIBINTL}" "${LIBBFD_TMP};iberty;${LIBINTL_TMP}" "${LIBBFD_TMP};iberty;dl;${LIBINBTL}"
		)
			UNSET (BFD_COMPILE_TEST CACHE)
			CHECK_C_SOURCE_COMPILES ("#include <ansidecl.h>
				#include <bfd.h>

				int main()
				{
					const char *dummy = bfd_errmsg(bfd_get_error());
				}"
				BFD_COMPILE_TEST
			)

			IF (BFD_COMPILE_TEST)
				SET (LIBBFD ${CMAKE_REQUIRED_LIBRARIES})
				UNSET (${CMAKE_REQUIRED_LIBRARIES})
				BREAK()
			ENDIF (BFD_COMPILE_TEST)	
		ENDFOREACH (
			CMAKE_REQUIRED_LIBRARIES "" "${LIBBFD_TMP}" "${LIBBFD_TMP};iberty" "${LIBBFD_TMP};dl" "${LIBBFD};iberty;dl" "${LIBBFD_TMP};${LIBINTL}" "${LIBBFD_TMP};iberty;${LIBINTL_TMP}" "${LIBBFD_TMP};iberty;dl;${LIBINBTL}"
		)
	ENDIF (NOT LIBBFD)

	IF (NOT LIBBFD)
		SET (HAVE_BFD FALSE)
		MESSAGE (STATUS "bfd.h found but can't link against it, disabling support")
	ENDIF (NOT LIBBFD)
ELSE (HAVE_BFD)
	MESSAGE (STATUS "bfd.h not found, disabling support")
ENDIF (HAVE_BFD)
