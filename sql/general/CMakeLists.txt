if (${PGSQL_VERSION} GREATER_EQUAL 110000)
  set(JOIN_LE "scalarlejoinsel")
  set(JOIN_GE "scalargejoinsel")
  set(FILE15 15_time_spgist)
  set(FILE44 44_temporal_spgist)
  if (${PGSQL_VERSION} GREATER_EQUAL 120000)
    set(FILE19 19_geo_constructors)
  endif()
else()
  set(JOIN_LE "scalarltjoinsel")
  set(JOIN_GE "scalargtjoinsel")
endif()

SET(LOCAL_FILES
  00_catalog
  01_period
  03_timestampset
  05_periodset
  07_rangetypes_ext
  11_timeops
  13_time_gist
  ${FILE15}
  17_time_aggfuncs
  ${FILE19}
  20_doublen
  21_tbox
  22_temporal
  23_temporal_tile
  24_tnumber_mathfuncs
  26_tbool_boolops
  27_ttext_textfuncs
  28_temporal_compops
  32_temporal_boxops
  34_temporal_posops
  36_tnumber_distance
  38_temporal_aggfuncs
  40_temporal_waggfuncs
  42_temporal_gist
  ${FILE44}
  99_tempcache
  )

message(STATUS "LOCAL_FILES=${LOCAL_FILES}")

foreach (f ${LOCAL_FILES})

  file(READ ${f}.in.sql CURR_CONTENTS)

  if ("${f}" MATCHES "01_period")
    #message(STATUS "${f} before = ${CURR_CONTENTS}")
    if (${PGSQL_VERSION} GREATER_EQUAL 110000)
      string(REGEX REPLACE "#if MOBDB_PGSQL_VERSION >= 110000" "-- here if" CURR_CONTENTS "${CURR_CONTENTS}")
      string(REGEX REPLACE "#endif" "-- here endif" CURR_CONTENTS "${CURR_CONTENTS}")
    else()
      string(REGEX REPLACE "#if MOBDB_PGSQL_VERSION >= 110000" "/**" CURR_CONTENTS "${CURR_CONTENTS}")
      string(REGEX REPLACE "#endif" "*/" CURR_CONTENTS "${CURR_CONTENTS}")
    endif()
    #message(STATUS "${f} after = ${CURR_CONTENTS}")
  endif()

  if ("${f}" MATCHES "13_time_gist|42_temporal_gist")
    if (${PGSQL_VERSION} LESS 110000)
      string(REGEX REPLACE "#if MOBDB_PGSQL_VERSION < 110000" "-- here if" CURR_CONTENTS "${CURR_CONTENTS}")
      string(REGEX REPLACE "#endif" "-- here endif" CURR_CONTENTS "${CURR_CONTENTS}")
    else()
      string(REGEX REPLACE "#if MOBDB_PGSQL_VERSION < 110000" "/**" CURR_CONTENTS "${CURR_CONTENTS}")
      string(REGEX REPLACE "#endif" "*/" CURR_CONTENTS "${CURR_CONTENTS}")
    endif()
  endif()

  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${f}.sql.in "${CURR_CONTENTS}")
  configure_file(${CMAKE_CURRENT_BINARY_DIR}/${f}.sql.in ${f}.sql @ONLY)

  list(APPEND PACKAGE_SQL_FILES  ${CMAKE_CURRENT_BINARY_DIR}/${f}.sql)
endforeach()

set(PROJECT_SQL_FILES ${PROJECT_SQL_FILES} ${PACKAGE_SQL_FILES} PARENT_SCOPE)
