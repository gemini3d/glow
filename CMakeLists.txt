cmake_minimum_required(VERSION 3.20...4.5)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR "please use out of source build
  cmake -B build")
endif()

get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT is_multi_config AND NOT (CMAKE_BUILD_TYPE OR DEFINED ENV{CMAKE_BUILD_TYPE}))
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Release default")
endif()

project(glow
LANGUAGES Fortran
VERSION 0.981.0.17
)

enable_testing()

include(GNUInstallDirs)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION}  CMake ${CMAKE_VERSION} Toolchain ${CMAKE_TOOLCHAIN_FILE}")

option(glow_BUILD_TESTING "Build tests" ${glow_IS_TOP_LEVEL})

# Necessary for shared library with Visual Studio / Windows oneAPI
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS true)

if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(glow_legacy_flag -std=legacy)
  set(glow_implicit_flag -fno-implicit-none)
endif()

file(GENERATE OUTPUT .gitignore CONTENT "*")

# to make more usable by external programs, put all Fortran .mod generated module files in a single directory.
set(CMAKE_Fortran_MODULE_DIRECTORY ${PROJECT_BINARY_DIR}/include)
file(MAKE_DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY})
# avoid race condition

set(cglow_src glow.f90 cglow.f90 fieldm.f solzen.f90 ssflux.f90 rcolum.f90 qback.f90 etrans.f90 exsect.f gchem.f90 bands.f90 ephoto.f90 egrid.f90 maxt.f90)
set(snoem_src snoem.f90 snoemint.f90 geomag.f90)
set(utils_src mzgrid.f90 conduct.f90 iri90.f)

set_property(SOURCE nrlmsise00.f iri90.f exsect.f fieldm.f
APPEND
PROPERTY COMPILE_OPTIONS ${glow_legacy_flag}
)

set_property(SOURCE msise00_data.f nrlmsise00.f iri90.f fieldm.f geomag.f90
APPEND
PROPERTY COMPILE_OPTIONS ${glow_implicit_flag}
)

add_library(msis00 nrlmsise00.f msise00_data.f)
target_compile_options(msis00 PRIVATE ${glow_fflags})
target_include_directories(msis00 PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set(glow_data_dir "${CMAKE_CURRENT_SOURCE_DIR}/data/" CACHE PATH "Directory for glow data files")

add_library(glow ${cglow_src} ${snoem_src} ${utils_src})
target_compile_options(glow PRIVATE ${glow_fflags})
target_link_libraries(glow PRIVATE msis00)
target_include_directories(glow PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

add_library(glow::glow ALIAS glow)

install(TARGETS glow msis00 EXPORT ${PROJECT_NAME}-targets)

install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/
TYPE INCLUDE
FILES_MATCHING PATTERN "*.mod"
)

install(DIRECTORY ${glow_data_dir}
DESTINATION share/${PROJECT_NAME}/data/
FILES_MATCHING PATTERN "*.dat"
)

install(DIRECTORY ${glow_data_dir}/iri90/
DESTINATION share/${PROJECT_NAME}/data/iri90
FILES_MATCHING PATTERN "*.asc"
)

# --- tests

if(glow_BUILD_TESTING)

add_executable(glowbasic glowbasic.f90)
target_link_libraries(glowbasic PRIVATE glow::glow)
add_test(NAME glow_basic
COMMAND glowbasic basic.nml
WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

endif()

include(cmake/install.cmake)
