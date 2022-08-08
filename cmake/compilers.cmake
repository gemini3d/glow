if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(glow_fflags $<$<COMPILE_LANGUAGE:Fortran>:-std=legacy>)
endif()
