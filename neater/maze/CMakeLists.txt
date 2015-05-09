cmake_minimum_required (VERSION 3.2.1 FATAL_ERROR)

project(Maze CXX)

#message("Your C++ compiler supports these C++ features:")
#foreach(i ${CMAKE_CXX_COMPILE_FEATURES})
#  message("${i}")
#endforeach()

set (Maze_VERSION_MAJOR 0)
set (Maze_VERSION_MINOR 0)
set (Maze_VERSION_PATCH 1)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

find_package (Threads)

add_executable(mz main.cpp)

set_property(TARGET mz PROPERTY CXX_STANDARD 14)
set_property(TARGET mz PROPERTY CXX_STANDARD_REQUIRED ON)

add_library(maze SHARED maze.cpp)
target_link_libraries (mz maze ${CMAKE_THREAD_LIBS_INIT})

set_property(TARGET maze PROPERTY CXX_STANDARD 14)
set_property(TARGET maze PROPERTY CXX_STANDARD_REQUIRED ON)
