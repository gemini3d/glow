cmake_minimum_required(VERSION 3.13...3.20)

project(glow
  LANGUAGES Fortran
  VERSION 0.981.0.5
  DESCRIPTION "NCAR GLOW ionospheric model"
  HOMEPAGE_URL https://github.com/gemini3d/glow)

include(CTest)

if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  set(_glow_old -std=legacy -Wno-pedantic -w -fno-implicit-none -Wno-error=array-bounds -fcheck=no-all)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  if(WIN32)
    set(_glow_old /nostand /nowarn /nocheck)
  else()
    set(_glow_old -nostand -nowarn -nocheck)
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Cray)
  set(_glow_old -m 4)
else()  # Flang, Nvidia, NAG, etc.
  set(_glow_old -w)
endif()

set(cglow_src glow.f90 cglow.f90 fieldm.f solzen.f90 ssflux.f90 rcolum.f90 qback.f90 etrans.f90 exsect.f gchem.f90 bands.f90 ephoto.f90 egrid.f90 maxt.f90)
set(snoem_src snoem.f90 snoemint.f90 geomag.f90)
set(utils_src mzgrid.f90 conduct.f90 iri90.f)

add_library(msis00 nrlmsise00.f msise00_data.f)
target_compile_options(msis00 PRIVATE ${_glow_old})
target_include_directories(msis00
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/include
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<INSTALL_INTERFACE:include>)
set_target_properties(msis00 PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)


add_library(glow ${cglow_src} ${snoem_src} ${utils_src})
target_compile_options(glow PRIVATE ${_glow_old})
target_link_libraries(glow PRIVATE msis00)
target_compile_definitions(glow INTERFACE
  $<BUILD_INTERFACE:DATADIR="${CMAKE_CURRENT_SOURCE_DIR}/data/">
  $<INSTALL_INTERFACE:DATADIR="data/">)
target_include_directories(glow
  PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/include
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<INSTALL_INTERFACE:include>)
set_target_properties(glow PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)

add_library(glow::glow INTERFACE IMPORTED GLOBAL)
target_link_libraries(glow::glow INTERFACE glow)

install(TARGETS glow msis00
  EXPORT ${PROJECT_NAME}Targets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/
  DESTINATION include
  FILES_MATCHING PATTERN "*.mod")

# --- tests

if(BUILD_TESTING)

add_executable(glowbasic glowbasic.f90)
target_link_libraries(glowbasic PRIVATE glow)
add_test(NAME glow_basic
  COMMAND $<TARGET_FILE:glowbasic> basic.nml
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

endif(BUILD_TESTING)

# --- install

include(cmake/install.cmake)
