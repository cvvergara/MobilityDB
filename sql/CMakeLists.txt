
add_subdirectory(general)

add_custom_target(all_sql_files ALL
  DEPENDS ${PROJECT_SQL_FILES})

message(STATUS "PROJECT_SQL_FILES=${PROJECT_SQL_FILES}")

foreach (f ${PROJECT_SQL_FILES})
  file(READ ${f} CURR_CONTENTS)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${SQLPP}.in "${CURR_CONTENTS}")
endforeach()

configure_file(${CMAKE_CURRENT_BINARY_DIR}/${SQLPP}.in ${CMAKE_CURRENT_BINARY_DIR}/${SQLPP}.sql COPYONLY)
#add_dependencies(all_sql_files ${CMAKE_CURRENT_BINARY_DIR}/${SQLPP}.sql.in)
