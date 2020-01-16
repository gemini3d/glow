cmake_minimum_required(VERSION 3.12)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(glow
  LANGUAGES Fortran
  VERSION 0.981
  DESCRIPTION "NCAR GLOW ionospheric model"
  HOMEPAGE_URL https://github.com/gemini3d/glow)
enable_testing()

if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  set(_glow_old -std=legacy -Wno-pedantic -w -fno-implicit-none -Wno-error=array-bounds -fcheck=no-all)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  if(WIN32)
    set(_glow_old /nowarn /nocheck)
  else()
    set(_glow_old -nowarn -nocheck)
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Cray)
  set(_glow_old -m 4)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL PGI)
  set(_glow_old -w)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Flang)
  set(_glow_old -w)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL NAG)
  set(_glow_old -w)
endif()

set(cglow_src glow.f90 cglow.f90 fieldm.f solzen.f90 ssflux.f90 rcolum.f90 qback.f90 etrans.f90 exsect.f gchem.f90 bands.f90 ephoto.f90 egrid.f90 maxt.f90)
set(snoem_src snoem.f90 snoemint.f90 geomag.f90)
set(utils_src mzgrid.f90 conduct.f90 iri90.f nrlmsise00.f)

add_library(glow ${cglow_src} ${snoem_src} ${utils_src})
target_compile_options(glow PRIVATE ${_glow_old})
target_include_directories(glow INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<INSTALL_INTERFACE:include>)
set_target_properties(glow PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
add_library(glow::glow ALIAS glow)

if(NOT PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
   return()
endif()

# --- tests

add_executable(glowbasic glowbasic.f90)
target_link_libraries(glowbasic PRIVATE glow::glow)

add_test(NAME glow_basic
  COMMAND $<TARGET_FILE:glowbasic> basic.nml
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})


set(CTEST_TEST_TIMEOUT 15)
# --- install config

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  if(WIN32)
    set(HOME $ENV{USERPROFILE})
  else()
    set(HOME $ENV{HOME})
  endif()

  set(CMAKE_INSTALL_PREFIX "${HOME}/.local/${PROJECT_NAME}" CACHE PATH "..." FORCE)
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/install.cmake)


# --- package
if(PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  set(CPACK_GENERATOR ZIP)
  set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/Glowlicense.txt")
  set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
  include(CPack)
endif()