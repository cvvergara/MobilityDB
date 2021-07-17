SET(LOCAL_FILES
  00_catalog
  01_period
  03_timestampset
  05_periodset
  07_rangetypes_ext
  11_timeops
  13_time_gist
  15_time_spgist
  17_time_aggfuncs
  19_geo_constructors
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
  44_temporal_spgist
  99_tempcache
  )

foreach (f ${LOCAL_FILES})
    configure_file(${f}.in.sql ${f}.sql)
    list(APPEND PACKAGE_SQL_FILES  ${CMAKE_CURRENT_BINARY_DIR}/${f}.sql)
    file(READ ${CMAKE_CURRENT_BINARY_DIR}/${f}.sql CURR_CONTENTS)
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${SQLPP}.in "${CURR_CONTENTS}")
endforeach()

configure_file(${CMAKE_CURRENT_BINARY_DIR}/${SQLPP}.in ${CMAKE_CURRENT_BINARY_DIR}/${SQLPP} COPYONLY)
add_custom_target(general_extension_file ALL
  DEPENDS
  ${CMAKE_CURRENT_BINARY_DIR}/${SQLPP}
  )


set(PROJECT_SQL_FILES ${PROJECT_SQL_FILES} ${PACKAGE_SQL_FILES} PARENT_SCOPE)
