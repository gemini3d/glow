if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(glow_fflags -std=legacy -fno-implicit-none)
endif()
