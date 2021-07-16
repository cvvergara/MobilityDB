# Find Proj
# ~~~~~~~~~
# Copyright (c) 2021, Vicky Vergara <vicky at georepublic.de>
# - Adjustments for MobilityDB
# - cmake >= 3.1
# Copyright (c) 2007, Martin Dobias <wonder.sk at gmail.com>
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
# CMake module to search for Proj library
#
# If it's found it sets PROJ_FOUND to TRUE
# and following variables are set:
#    PROJ_INCLUDE_DIR
#    PROJ_LIBRARY

# FIND_PATH and FIND_LIBRARY normally search standard locations
# before the specified paths. To search non-standard paths first,
# FIND_* is invoked first with specified paths and NO_DEFAULT_PATH
# and then again with no specified paths to search the default
# locations. When an earlier FIND_* succeeds, subsequent FIND_*s
# searching for the same item do nothing.

# try to use framework on mac
# want clean framework path, not unix compatibility path
IF (APPLE)
  IF (CMAKE_FIND_FRAMEWORK MATCHES "FIRST"
      OR CMAKE_FRAMEWORK_PATH MATCHES "ONLY"
      OR NOT CMAKE_FIND_FRAMEWORK)
    SET (CMAKE_FIND_FRAMEWORK_save ${CMAKE_FIND_FRAMEWORK} CACHE STRING "" FORCE)
    SET (CMAKE_FIND_FRAMEWORK "ONLY" CACHE STRING "" FORCE)
    #FIND_PATH(PROJ_INCLUDE_DIR PROJ/proj_api.h)
    FIND_LIBRARY(PROJ_LIBRARY PROJ)
    IF (PROJ_LIBRARY)
      # FIND_PATH doesn't add "Headers" for a framework
      SET (PROJ_INCLUDE_DIR ${PROJ_LIBRARY}/Headers CACHE PATH "Path to a file.")
    ENDIF (PROJ_LIBRARY)
    SET (CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK_save} CACHE STRING "" FORCE)
  ENDIF ()
ENDIF (APPLE)

FIND_PATH(PROJ_INCLUDE_DIR proj_api.h)
message(STATUS "PROJ_INCLUDE_DIR=${PROJ_INCLUDE_DIR}")

FIND_LIBRARY(PROJ_LIBRARY NAMES proj_i proj)
message(STATUS "PROJ_LIBRARY=${PROJ_LIBRARY}")

IF (PROJ_INCLUDE_DIR AND PROJ_LIBRARY)
  FILE(READ ${PROJ_INCLUDE_DIR}/proj_api.h proj_version)
  STRING(REGEX REPLACE "^.*PJ_VERSION ([0-9]+).*$" "\\1" PROJ_VERSION_NUMB "${proj_version}")
  message(STATUS "PROJ_VERSION_NUMB=${PROJ_VERSION_NUMB}")

  # This will break if 4.10.0 ever will be released (highly unlikely)
  STRING(REGEX REPLACE "([0-9])([0-9])([0-9])" "\\1" PROJ_VERSION_MAJOR "${PROJ_VERSION_NUMB}")
  STRING(REGEX REPLACE "([0-9])([0-9])([0-9])" "\\2" PROJ_VERSION_MINOR "${PROJ_VERSION_NUMB}")
  STRING(REGEX REPLACE "([0-9])([0-9])([0-9])" "\\3" PROJ_VERSION_PATCH "${PROJ_VERSION_NUMB}")
  STRING(CONCAT PROJ_VERSION_STR "${PROJ_VERSION_MAJOR}.${PROJ_VERSION_MINOR}.${PROJ_VERSION_PATCH}")
  message(STATUS "PROJ_VERSION_STR=${PROJ_VERSION_STR}")
ENDIF ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Proj
  REQUIRED_VARS PROJ_INCLUDE_DIR PROJ_LIBRARY PROJ_VERSION_NUMB
  VERSION_VAR PROJ_VERSION_STR)

mark_as_advanced(PROJ_INCLUDE_DIR PROJ_LIBRARY PROJ_VERSION_NUMB)
