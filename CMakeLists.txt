cmake_minimum_required(VERSION 3.1)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(Glow VERSION 0.981 LANGUAGES Fortran)
enable_testing()

# The Glow code need to be updated to be more standards compliant.
if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  set(old -w -std=legacy)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  if(WIN32)
    set(old /nowarn)
  else()
    set(old -nowarn)
  endif()
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL PGI)
  set(old -w)
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL Flang)
  set(old -w)
endif()

set(cglow_src glow.f90 cglow.f90 fieldm.f solzen.f90 ssflux.f90 rcolum.f90 qback.f90 etrans.f90 exsect.f gchem.f90 bands.f90 ephoto.f90 egrid.f90 maxt.f90)
set(snoem_src snoem.f90 snoemint.f90 geomag.f90)
set(utils_src mzgrid.f90 conduct.f90)

add_library(msis_iri nrlmsise00.f iri90.f)
target_compile_options(msis_iri PRIVATE ${old})

add_library(cglow ${cglow_src} ${snoem_src} ${utils_src})
target_link_libraries(cglow PRIVATE msis_iri)

add_executable(glowbasic glowbasic.f90)
target_link_libraries(glowbasic PRIVATE cglow)

add_test(NAME GlowBasic COMMAND glowbasic basic.nml
  WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR})
set_tests_properties(GlowBasic PROPERTIES TIMEOUT 10)