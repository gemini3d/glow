cmake_minimum_required(VERSION 3.14...3.22)

file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/VERSION PROJECT_VERSION
  REGEX "^([0-9]+\.[0-9]+\.[0-9]+)" LIMIT_INPUT 16 LENGTH_MAXIMUM 16 LIMIT_COUNT 1)

project(glow
LANGUAGES Fortran
VERSION ${PROJECT_VERSION}
DESCRIPTION "NCAR GLOW ionospheric model"
HOMEPAGE_URL https://github.com/gemini3d/glow
)

include(CTest)

include(cmake/options.cmake)

if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  set(_glow_old -std=legacy)
endif()

set(cglow_src glow.f90 cglow.f90 fieldm.f solzen.f90 ssflux.f90 rcolum.f90 qback.f90 etrans.f90 exsect.f gchem.f90 bands.f90 ephoto.f90 egrid.f90 maxt.f90)
set(snoem_src snoem.f90 snoemint.f90 geomag.f90)
set(utils_src mzgrid.f90 conduct.f90 iri90.f)

add_library(msis00 nrlmsise00.f msise00_data.f)
target_compile_options(msis00 PRIVATE ${_glow_old})
target_include_directories(msis00 PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
$<INSTALL_INTERFACE:include>
)
set_target_properties(msis00 PROPERTIES
Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
)


add_library(glow ${cglow_src} ${snoem_src} ${utils_src})
target_compile_options(glow PRIVATE ${_glow_old})
target_link_libraries(glow PRIVATE msis00)
target_compile_definitions(glow INTERFACE
# must have trailing / on each of these!
$<BUILD_INTERFACE:DATADIR="${CMAKE_CURRENT_SOURCE_DIR}/data/">
$<INSTALL_INTERFACE:DATADIR="${CMAKE_INSTALL_PREFIX}/share/data/${PROJECT_NAME}/">
)
target_include_directories(glow PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
$<INSTALL_INTERFACE:include>
)
set_target_properties(glow PROPERTIES
Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
)

add_library(glow::glow INTERFACE IMPORTED GLOBAL)
target_link_libraries(glow::glow INTERFACE glow)

install(TARGETS glow msis00 EXPORT ${PROJECT_NAME}-targets)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/
TYPE INCLUDE
FILES_MATCHING PATTERN "*.mod"
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data/
DESTINATION share/data/${PROJECT_NAME}
FILES_MATCHING PATTERN "*.dat"
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data/iri90/
DESTINATION share/data/${PROJECT_NAME}/iri90
FILES_MATCHING PATTERN "*.asc"
)

# --- tests

if(BUILD_TESTING)

add_executable(glowbasic glowbasic.f90)
target_link_libraries(glowbasic PRIVATE glow)
add_test(NAME glow_basic
COMMAND $<TARGET_FILE:glowbasic> basic.nml
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

endif(BUILD_TESTING)

# --- install

include(cmake/install.cmake)
