IF (BUILT_CRYPTO)
	SET (WAIT_FOR_CRYPTO FALSE CACHE INTERNAL "Set if crytopp is neded to be built")

	EXTERNALPROJECT_ADD (CRYPTO
		GIT_REPOSITORY https://github.com/weidai11/cryptopp.git
		GIT_TAG CRYPTOPP_8_2_0
		GIT_PROGRESS TRUE
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND ""
	)

	EXTERNALPROJECT_GET_PROPERTY (CRYPTO SOURCE_DIR)
	SET (CRYPTOPP_HEADER_PATH ${SOURCE_DIR} CACHE PATH "Search hint for crypto++ headers" FORCE)
	SET (CRYTOPP_LIB_SEARCH_PATH ${SOURCE_DIR} CACHE PATH "Search hint for crypto++ headers" FORCE)
ENDIF (BUILT_CRYPTO)

IF (NOT CRYPTOPP_CONFIG_FILE)
	SET (CRYPTOPP_SEARCH_SUFFIXES "cryptopp" "crypto++")

	IF (NOT CRYPTOPP_INCLUDE_PREFIX)
		FIND_PATH (CRYPTOPP_INCLUDE_PREFIX_TMP
			NAMES cryptlib.h
			PATHS "${CRYTOPP_HEADER_PATH}"
			PATH_SUFFIXES ${CRYPTOPP_SEARCH_SUFFIXES}
			DOC "cryptopp include path"
		)

		IF (CRYPTOPP_INCLUDE_PREFIX_TMP AND NOT SEARCH_DIR_CRYPTOPP_HEADER)
			FOREACH (SUFFIX ${CRYPTOPP_SEARCH_SUFFIXES})
				STRING (FIND ${CRYPTOPP_INCLUDE_PREFIX_TMP} ${SUFFIX} SUFFIX_FOUND )
				IF (SUFFIX_FOUND GREATER 0)
					SET (CRYPTOPP_INCLUDE_PREFIX ${SUFFIX} CACHE STRING "cryptopp include prefix" FORCE)
					UNSET (SUFFIX_FOUND)
				ENDIF (SUFFIX_FOUND GREATER 0)
			ENDFOREACH (SUFFIX CRYPTOPP_SEARCH_SUFFIXES)
		ELSE (CRYPTOPP_INCLUDE_PREFIX_TMP AND NOT SEARCH_DIR_CRYPTOPP_HEADER)
			SET (CRYPTOPP_INCLUDE_PREFIX ${CRYPTOPP_INCLUDE_PREFIX_TMP} CACHE STRING "cryptopp include prefix" FORCE)
		ENDIF (CRYPTOPP_INCLUDE_PREFIX_TMP AND NOT SEARCH_DIR_CRYPTOPP_HEADER)
	ENDIF (NOT CRYPTOPP_INCLUDE_PREFIX)

	IF (CRYPTOPP_INCLUDE_PREFIX)
		MESSAGE (STATUS "Found cryptlib.h in ${CRYPTOPP_INCLUDE_PREFIX}")
	ELSE (CRYPTOPP_INCLUDE_PREFIX)
		IF (NOT DOWNLOAD_AND_BUILD_DEPS)
			MESSAGE (FATAL_ERROR "cryptlib.h not found")
		ENDIF (NOT DOWNLOAD_AND_BUILD_DEPS)
	ENDIF (CRYPTOPP_INCLUDE_PREFIX)

	FIND_LIBRARY (CRYPTOPP_LIBRARY
		NAMES crypto++ cryptlib
	)

	IF (NOT CRYPTOPP_LIBRARY)
		FIND_LIBRARY (CRYPTOPP_LIBRARY
			NAMES cryptopp cryptlib
			PATHS ${CRYTOPP_LIB_SEARCH_PATH}
		)
	ENDIF (NOT CRYPTOPP_LIBRARY)

	MESSAGE (STATUS "Found libcrypto++ in ${CRYPTOPP_LIBRARY}")

	FIND_FILE (CRYPTOPP_CONFIG_FILE
		NAME ${CRYPTOPP_INCLUDE_PREFIX}/config.h
		PATHS ENV
	)

	IF (NOT CRYPTOPP_CONFIG_FILE)
		FIND_FILE (CRYPTOPP_CONFIG_FILE
			NAME config.h
			PATHS ${CRYTOPP_HEADER_PATH}
		)
	ENDIF (NOT CRYPTOPP_CONFIG_FILE)

	IF (NOT CRYPTOPP_CONFIG_FILE AND NOT DOWNLOAD_AND_BUILD_DEPS)
		MESSAGE (FATAL_ERROR "crypto++ config.h not found")
	ENDIF (NOT CRYPTOPP_CONFIG_FILE AND NOT DOWNLOAD_AND_BUILD_DEPS)

	IF (CRYPTOPP_CONFIG_FILE)
		FILE (STRINGS ${CRYPTOPP_CONFIG_FILE} CRYPTTEST_OUTPUT REGEX "define CRYPTOPP_VERSION")
		STRING (REGEX REPLACE "#define CRYPTOPP_VERSION " "" CRYPTOPP_VERSION "${CRYPTTEST_OUTPUT}")
		STRING (REGEX REPLACE "([0-9])([0-9])([0-9])" "\\1.\\2.\\3" CRYPTOPP_VERSION "${CRYPTOPP_VERSION}")


		IF (${CRYPTOPP_VERSION} VERSION_LESS ${MIN_CRYPTOPP_VERSION})
			MESSAGE (FATAL_ERROR "crypto++ version ${CRYPTOPP_VERSION} is too old")
		ELSE (${CRYPTOPP_VERSION} VERSION_LESS ${MIN_CRYPTOPP_VERSION})
			MESSAGE (STATUS "crypto++ version ${CRYPTOPP_VERSION} -- OK")
		ENDIF (${CRYPTOPP_VERSION} VERSION_LESS ${MIN_CRYPTOPP_VERSION})
	ENDIF (CRYPTOPP_CONFIG_FILE)
ENDIF (NOT CRYPTOPP_CONFIG_FILE)

IF (NOT CRYPTOPP_CONFIG_FILE AND DOWNLOAD_AND_BUILD_DEPS)
	EXTERNALPROJECT_ADD (CRYPTO
		GIT_REPOSITORY https://github.com/weidai11/cryptopp.git
		GIT_TAG CRYPTOPP_8_2_0
		GIT_PROGRESS TRUE
		CONFIGURE_COMMAND ""
		BUILD_IN_SOURCE TRUE
		BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -f GNUmakefile
		INSTALL_COMMAND ${CMAKE_COMMAND} ${amule_BINARY_DIR} -DBUILT_CRYPTO=TRUE
	)

	EXTERNALPROJECT_GET_PROPERTY (CRYPTO SOURCE_DIR)
	INSTALL (CODE ${CMAKE_MAKE_PROGRAM} -f ${SOURCE_DIR}/GNUmakefile install)
	SET (WAIT_FOR_CRYPTO TRUE CACHE INTERNAL "Set if cryptopp is neded to be built")
ENDIF (NOT CRYPTOPP_CONFIG_FILE AND DOWNLOAD_AND_BUILD_DEPS)