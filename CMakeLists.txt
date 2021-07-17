cmake_minimum_required(VERSION 3.2)

if ( ${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
        message(FATAL_ERROR "In-source builds not allowed.
        Please make a new directory (called a build directory) and run CMake from there.
        You may need to remove 'CMakeCache.txt' and 'CMakeFiles/'.")
endif()

project(MobilityDB VERSION 1.0)
set(MOBILITYDB_VERSION 1.0)
include(CheckSymbolExists)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(SRCS
src/general/geo_constructors.c
src/general/doublen.c
src/general/lifting.c
src/general/period.c
src/general/periodset.c
src/general/rangetypes_ext.c
src/general/skiplist.c
src/general/tbool_boolops.c
src/general/tbox.c
src/general/tempcache.c
src/general/temporal.c
src/general/tinstant.c
src/general/tinstantset.c
src/general/tsequence.c
src/general/tsequenceset.c
src/general/temporal_aggfuncs.c
src/general/temporal_analyze.c
src/general/temporal_boxops.c
src/general/temporal_compops.c
src/general/temporal_gist.c
src/general/tnumber_mathfuncs.c
src/general/temporal_parser.c
src/general/temporal_posops.c
src/general/temporal_selfuncs.c
src/general/temporal_spgist.c
src/general/temporal_tile.c
src/general/temporal_util.c
src/general/temporal_waggfuncs.c
src/general/timeops.c
src/general/timestampset.c
src/general/time_aggfuncs.c
src/general/time_analyze.c
src/general/time_gist.c
src/general/time_selfuncs.c
src/general/time_spgist.c
src/general/tnumber_distance.c
src/general/tnumber_gist.c
src/general/tnumber_selfuncs.c
src/general/tnumber_spgist.c
src/general/ttext_textfuncs.c
)

set(SQL
sql/general/00_catalog.in.sql
sql/general/01_period.in.sql
sql/general/03_timestampset.in.sql
sql/general/05_periodset.in.sql
sql/general/07_rangetypes_ext.in.sql
sql/general/11_timeops.in.sql
sql/general/13_time_gist.in.sql
sql/general/15_time_spgist.in.sql
sql/general/17_time_aggfuncs.in.sql
sql/general/19_geo_constructors.in.sql
sql/general/20_doublen.in.sql
sql/general/21_tbox.in.sql
sql/general/22_temporal.in.sql
sql/general/23_temporal_tile.in.sql
sql/general/24_tnumber_mathfuncs.in.sql
sql/general/26_tbool_boolops.in.sql
sql/general/27_ttext_textfuncs.in.sql
sql/general/28_temporal_compops.in.sql
sql/general/32_temporal_boxops.in.sql
sql/general/34_temporal_posops.in.sql
sql/general/36_tnumber_distance.in.sql
sql/general/38_temporal_aggfuncs.in.sql
sql/general/40_temporal_waggfuncs.in.sql
sql/general/42_temporal_gist.in.sql
sql/general/44_temporal_spgist.in.sql
sql/general/99_tempcache.in.sql
)

include(CTest)
enable_testing()

#-------------------------------------
# Verify PostgreSQL Version
#-------------------------------------
set(PG_MIN_MAJOR_VERSION "10")
set(PG_MAX_MAJOR_VERSION "14")

#---------------------------------------------
#---------------------------------------------
# PostgreSQL
#---------------------------------------------
#---------------------------------------------

find_package(PostgreSQL)
if(NOT POSTGRESQL_FOUND OR NOT POSTGRESQL_VERSION_STRING)
  message("HERE")
  message(FATAL_ERROR "PostgreSQL not found - Please check your PostgreSQL installation.")
endif()

message(STATUS "POSTGRESQL_VERSION_STRING=${POSTGRESQL_VERSION_STRING}")
string(SUBSTRING "${POSTGRESQL_VERSION_STRING}" 11 -1 POSTGRESQL_VERSION)

# for XbetaY XalphaY XrcY -> X.Y
string(REGEX REPLACE "^([0-9]+)[beta|alpha|rc|devel].*" "\\1.0" POSTGRESQL_VERSION ${POSTGRESQL_VERSION})

#for X.Y.Z -> XY  Y<10
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*" "\\10000" PGSQL_VERSION_MAYOR ${POSTGRESQL_VERSION})
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*" "\\2" PGSQL_VERSION_MICRO ${POSTGRESQL_VERSION})
message("${PGSQL_VERSION_MICRO}" + "${PGSQL_VERSION_MAYOR}")
math(EXPR PGSQL_VERSION "${PGSQL_VERSION_MICRO}+${PGSQL_VERSION_MAYOR}")


if("${POSTGRESQL_VERSION}" VERSION_LESS "${PG_MIN_MAJOR_VERSION}")
  message(FATAL_ERROR " PostgreSQL ${PG_MIN_MAJOR_VERSION} or greater is required.")
endif("${POSTGRESQL_VERSION}" VERSION_LESS "${PG_MIN_MAJOR_VERSION}")

#-------
include_directories(SYSTEM ${POSTGRESQL_INCLUDE_DIR})
if(WIN32)
    include_directories(SYSTEM ${POSTGRESQL_INCLUDE_DIR}/port/win32)
    if(MSVC)
        include_directories(SYSTEM ${POSTGRESQL_INCLUDE_DIR}/port/win32_msvc/)
    endif()
endif()

# The definitions are not used on the code
add_definitions(-DMOBDB_PGSQL_VERSION=${PGSQL_VERSION})
add_definitions(-DMOBDB_PGSQL_VERSION_STR="${POSTGRESQL_VERSION}")
message(STATUS "PGSQL_VERSION=${PGSQL_VERSION}")
message(STATUS "POSTGRESQL_VERSION=${POSTGRESQL_VERSION}")


#[[
find_program(PGCONFIG pg_config)
if (NOT PGCONFIG)
	message(FATAL_ERROR "Could not find pg_config")
endif ()
execute_process(COMMAND ${PGCONFIG} --version OUTPUT_VARIABLE PG_VERSION_STRING OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(
		COMMAND ${PGCONFIG} --version
		COMMAND sed "-es/.* //"
		COMMAND sed "s/[A-Za-z].*$//"
		COMMAND sed "s/[A-Za-z].*$//"
		COMMAND tr "." " "
		COMMAND awk "{printf \"%d%04d\", $1, $2}"
		OUTPUT_VARIABLE PG_FULL_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${PGCONFIG} --version COMMAND sed "-es/.* //" "-es/\\..*//" OUTPUT_VARIABLE PG_MAJOR_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)

if(${PG_MAJOR_VERSION} LESS ${PG_MIN_MAJOR_VERSION})
	message(FATAL_ERROR "Wrong PostgreSQL version: found ${PG_VERSION_STRING}, minimum required is ${PG_MIN_MAJOR_VERSION}")
elseif(${PG_MAX_MAJOR_VERSION} LESS ${PG_MAJOR_VERSION})
	message(FATAL_ERROR "Wrong PostgreSQL version: found ${PG_VERSION_STRING}, maximum supported is ${PG_MAX_MAJOR_VERSION}")
endif()
message("Found compatible ${PG_VERSION_STRING}")


# The definitions are added but not used on the code
set(MOBDB_DEFS -DMOBDB_PGSQL_VERSION=${PG_FULL_VERSION} -DMOBDB_PGSQL_VERSION_STR="${PG_VERSION_STRING}")
add_definitions(${MOBDB_DEFS})
message(STATUS "PG_VERSION_STRING=${PG_VERSION_STRING}")
message(STATUS "PG_FULL_VERSION=${PG_FULL_VERSION}")

execute_process(COMMAND ${PGCONFIG} --includedir --includedir-server OUTPUT_VARIABLE PostgreSQL_ACTUAL_INCLUDE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)

include_directories(${PostgreSQL_ACTUAL_INCLUDE_DIR})
include_directories("include")
]]

include_directories(${PROJECT_SOURCE_DIR}/include)


add_definitions(-Wall -Wextra -std=gnu1x -Wno-unused-parameter)
if (CMAKE_COMPILER_IS_GNUCC)
	if (WITH_COVERAGE)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-arcs -ftest-coverage")
		set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fprofile-arcs -ftest-coverage")
	endif ()
endif ()

# TODO is there a reason to optimize with debug?
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -O0")

string(TOLOWER ${CMAKE_PROJECT_NAME} LCNAME)

set(CONTROLIN "control.in")
set(CONTROLOUT "${LCNAME}.control")
set(SQLPP "${LCNAME}--${MOBILITYDB_VERSION}.sql.c")
set(SQLOUT "${LCNAME}--${MOBILITYDB_VERSION}.sql")

execute_process(COMMAND ${POSTGRESQL_PG_CONFIG} --sharedir OUTPUT_VARIABLE PostgreSQL_SHARE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE) # FIXME: I don't think this work on Windows
execute_process(COMMAND ${POSTGRESQL_PG_CONFIG} --pkglibdir OUTPUT_VARIABLE PostgreSQL_EXTLIB_DIR OUTPUT_STRIP_TRAILING_WHITESPACE) # FIXME: I don't think this work on Windows

add_custom_target(sqlscript ALL DEPENDS ${CMAKE_BINARY_DIR}/${SQLOUT})
add_custom_target(control ALL DEPENDS ${CMAKE_BINARY_DIR}/${CONTROLOUT})

add_library(${CMAKE_PROJECT_NAME} MODULE ${SRCS})

if (APPLE)
	SET_TARGET_PROPERTIES(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,-undefined,dynamic_lookup -bundle_loader /usr/local/bin/postgres")
endif ()

find_library(HAS_LWGEOM lwgeom)
if (HAS_LWGEOM)
  # Proj is required by lwgeom
  find_package(Proj REQUIRED)
  include_directories(SYSTEM ${PROJ_INCLUDE_DIR})
  add_definitions(-DPROJ_VERSION_NUMB=${PROJ_VERSION_NUMB})

  MESSAGE(STATUS "Found LWGEOM at ${HAS_LWGEOM} - compiling with PostGIS support")
  if(NOT EXISTS "${PostgreSQL_EXTLIB_DIR}/postgis-2.5.so")
    message(WARNING "Could not find postgis-2.5.so; only PostGIS 2.5 is currently supported")
  endif()
else()
  message(FATAL_ERROR "Could not find lwgeom; ")
endif ()

find_package(JSON-C REQUIRED)

include("test/scripts/test.cmake")
include("point/point.cmake")
include("npoint/npoint.cmake")

find_package(GSL REQUIRED)
message(STATUS "GSL_CLBAS_LIBRARY=${GSL_CLBAS_LIBRARY}")
message(STATUS "GSL_CBLAS_LIBRARY_DEBUG=${GSL_CLBAS_LIBRARY_DEBUG}")
message(STATUS "GSL_CONFIG_EXECUTABLE=${GSL_CONFIG_EXECUTABLE}")
message(STATUS "GSL_LIBRARY=${GSL_LIBRARY}")
message(STATUS "GSL_LIBRARY_DEBUG=${GSL_LIBRARY_DEBUG}")
target_link_libraries(${CMAKE_PROJECT_NAME} GSL::gsl GSL::gslcblas)

#[[
find_library(HAS_GSLCBLAS gslcblas)
find_library(HAS_GSL gsl)
if (HAS_GSL AND HAS_GSLCBLAS)
   MESSAGE(STATUS "Found GSL at ${HAS_GSL}, Found GSLCBLAS at ${HAS_GSLCBLAS}")
   target_link_libraries(${CMAKE_PROJECT_NAME} ${HAS_GSL}) # GSL)
   target_link_libraries(${CMAKE_PROJECT_NAME} ${HAS_GSLCBLAS}) # GSLCBLAS)
   include_directories(${GSL_INCLUDE_DIR})
   include_directories(${GSLCBLAS_INCLUDE_DIR})
else()
    message(FATAL_ERROR "Could not find gsl or gslcblas; ")
endif ()
]]

check_symbol_exists(ffsl "string.h" HAS_FFSL)
if(NOT HAS_FFSL)
       add_definitions(-D NO_FFSL)
endif()

add_subdirectory(sql)
add_custom_command(
	OUTPUT ${SQLPP}
	COMMAND mkdir -p ${CMAKE_BINARY_DIR}/sqlin
	COMMAND cp ${SQL} ${CMAKE_BINARY_DIR}/sqlin/
	COMMAND cd ${CMAKE_BINARY_DIR}/sqlin/ && find -type f | sort | xargs cat > ${CMAKE_BINARY_DIR}/${SQLPP}
	WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
	DEPENDS ${SQL})

add_custom_command(
	OUTPUT ${SQLOUT}
	COMMAND "${CMAKE_C_COMPILER}" ${MOBDB_DEFS} -E ${SQLPP} | grep -v '^\#' > ${SQLOUT}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	DEPENDS ${SQLPP})
#DEPENDS general_extension_file)

add_custom_command(
	OUTPUT ${CONTROLOUT}
	COMMAND cat ${CONTROLIN} | sed -e's/LIBNAME/${CMAKE_PROJECT_NAME}/' -e's/VERSION/${MOBILITYDB_VERSION}/'  > ${CMAKE_BINARY_DIR}/${CONTROLOUT}
	WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
	DEPENDS ${CONTROLIN})

install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION "${PostgreSQL_EXTLIB_DIR}")
install(FILES "${CMAKE_BINARY_DIR}/${CONTROLOUT}" DESTINATION "${PostgreSQL_SHARE_DIR}/extension")
install(FILES "${CMAKE_BINARY_DIR}/${SQLOUT}" DESTINATION "${PostgreSQL_SHARE_DIR}/extension")

add_custom_target(install_restart
                  $(MAKE) install
                  COMMAND systemctl restart postgresql
                  DEPENDS ${PROJECT_NAME}
                  COMMENT "Restarting PostgreSQL")


