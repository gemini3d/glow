include(GNUInstallDirs)
include(ExternalProject)

if(BUILD_SHARED_LIBS)
  if(WIN32)
    set(GLOW_LIBRARIES
    ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}glow${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}msis00${CMAKE_SHARED_LIBRARY_SUFFIX}
    )
  else()
    set(GLOW_LIBRARIES
    ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}glow${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}msis00${CMAKE_SHARED_LIBRARY_SUFFIX}
    )
  endif()
else()
  set(GLOW_LIBRARIES
  ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}glow${CMAKE_STATIC_LIBRARY_SUFFIX}
  ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}msis00${CMAKE_STATIC_LIBRARY_SUFFIX}
  )
endif()

set(GLOW_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include)

set(glow_cmake_args
-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
-DBUILD_TESTING:BOOL=false
)

ExternalProject_Add(GLOW
GIT_REPOSITORY ${glow_git}
GIT_TAG ${glow_tag}
CMAKE_ARGS ${glow_cmake_args}
CMAKE_GENERATOR ${EXTPROJ_GENERATOR}
BUILD_BYPRODUCTS ${GLOW_LIBRARIES}
INACTIVITY_TIMEOUT 15
CONFIGURE_HANDLED_BY_BUILD true
)

file(MAKE_DIRECTORY ${GLOW_INCLUDE_DIRS})
# avoid generate race condition

add_library(glow::glow INTERFACE IMPORTED)
target_link_libraries(glow::glow INTERFACE ${GLOW_LIBRARIES})
target_include_directories(glow::glow INTERFACE ${GLOW_INCLUDE_DIRS})
target_compile_definitions(glow::glow INTERFACE DATADIR="${CMAKE_INSTALL_PREFIX}/share/data/glow/")
# DATADIR comes from glow project BUILD_INTERFACE COMPILE_DEFINITIONS


add_dependencies(glow::glow GLOW)
