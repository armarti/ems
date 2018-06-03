cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "ems")
set(PROJECT_VERSION "1.4.1")
set(PY_VERSION "3.5")

add_definitions(-DBUILD_PYTHON)
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION})

set(PYTHON_EXECUTABLE "${CMAKE_SOURCE_DIR}/.conda${PY_VERSION}/bin/python${PY_VERSION}")
find_package(PythonInterp ${PY_VERSION} REQUIRED)
find_package(PythonLibs ${PY_VERSION} REQUIRED)

set(SOURCES
    "src/ems.cc"
    "src/collectives.cc"
    "src/ems_alloc.cc"
    "src/loops.cc"
    "src/primitives.cc"
    "src/rmw.cc"
    "include/ems/ems.h"
    "include/ems/ems_alloc.h"
    "include/ems/ems_proto.h"
    "include/ems/ems_types.h"
    "include/ems/nodejs.h"
)

include_directories(${PROJECT_NAME}
    "./include"
    ${PYTHON_INCLUDE_DIRS}
    ${PYTHON_INCLUDE_DIR}
)

add_library(${PROJECT_NAME} MODULE ${SOURCES})
target_link_libraries(${PROJECT_NAME} ${PYTHON_LIBRARIES})
