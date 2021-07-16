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

FIND_PATH(PROJ_INCLUDE_DIR proj_api.h proj.h)
message(STATUS "PROJ_INCLUDE_DIR=${PROJ_INCLUDE_DIR}")

FIND_LIBRARY(PROJ_LIBRARY NAMES proj_i proj)
message(STATUS "PROJ_LIBRARY=${PROJ_LIBRARY}")

IF (PROJ_INCLUDE_DIR AND PROJ_LIBRARY)
  IF (EXISTS ${PROJ_INCLUDE_DIR}/proj.h AND EXISTS ${PROJ_INCLUDE_DIR}/proj_experimental.h)
    FILE(READ ${PROJ_INCLUDE_DIR}/proj.h proj_version)
    STRING(REGEX REPLACE "^.*PROJ_VERSION_MAJOR +([0-9]+).*$" "\\1" PROJ_VERSION_MAJOR "${proj_version}")
    STRING(REGEX REPLACE "^.*PROJ_VERSION_MINOR +([0-9]+).*$" "\\1" PROJ_VERSION_MINOR "${proj_version}")
    STRING(REGEX REPLACE "^.*PROJ_VERSION_PATCH +([0-9]+).*$" "\\1" PROJ_VERSION_PATCH "${proj_version}")
    STRING(CONCAT PROJ_VERSION_STR "${PROJ_VERSION_MAJOR}.${PROJ_VERSION_MINOR}.${PROJ_VERSION_PATCH}")
    message(STATUS "PROJ_VERSION_STR=${PROJ_VERSION_STR}")
  ELSE()
    FILE(READ ${PROJ_INCLUDE_DIR}/proj_api.h proj_version)
    STRING(REGEX REPLACE "^.*PJ_VERSION ([0-9]+).*$" "\\1" proj_version "${proj_version}")

    # This will break if 4.10.0 ever will be released (highly unlikely)
    STRING(REGEX REPLACE "([0-9])([0-9])([0-9])" "\\1" PROJ_VERSION_MAJOR "${proj_version}")
    STRING(REGEX REPLACE "([0-9])([0-9])([0-9])" "\\2" PROJ_VERSION_MINOR "${proj_version}")
    STRING(REGEX REPLACE "([0-9])([0-9])([0-9])" "\\3" PROJ_VERSION_PATCH "${proj_version}")
    STRING(CONCAT PROJ_VERSION_STR "${PROJ_VERSION_MAJOR}.${PROJ_VERSION_MINOR}.${PROJ_VERSION_PATCH}")
    message(STATUS "PROJ_VERSION_STR2=${PROJ_VERSION_STR}")

    # Minimum Proj version required is 4.9.3
    IF ((PROJ_VERSION_MAJOR EQUAL 4) AND ((PROJ_VERSION_MINOR LESS 9) OR ((PROJ_VERSION_MINOR EQUAL 9) AND (PROJ_VERSION_PATCH LESS 3))))
      MESSAGE(FATAL_ERROR "Found Proj: ${PROJ_VERSION_MAJOR}.${PROJ_VERSION_MINOR}.${PROJ_VERSION_PATCH}. Cannot build QGIS using Proj older than 4.9.3.")
    ENDIF((PROJ_VERSION_MAJOR EQUAL 4) AND ((PROJ_VERSION_MINOR LESS 9) OR ((PROJ_VERSION_MINOR EQUAL 9) AND (PROJ_VERSION_PATCH LESS 3))))
  ENDIF(EXISTS ${PROJ_INCLUDE_DIR}/proj.h AND EXISTS ${PROJ_INCLUDE_DIR}/proj_experimental.h)
  IF (NOT PROJ_FIND_QUIETLY)
    MESSAGE(STATUS "Found Proj: ${PROJ_LIBRARY} version ${PROJ_VERSION_MAJOR} ${PROJ_VERSION_STR}")
  ENDIF (NOT PROJ_FIND_QUIETLY)

  INCLUDE_DIRECTORIES(BEFORE SYSTEM ${PROJ_INCLUDE_DIR})
  ADD_DEFINITIONS(-DPROJ_VERSION_MAJOR=${PROJ_VERSION_MAJOR})
  SET(PROJ_FOUND TRUE)
ENDIF ()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Proj
  REQUIRED_VARS PROJ_INCLUDE_DIR PROJ_LIBRARY PROJ_VERSION_MAJOR)
