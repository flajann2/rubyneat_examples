cmake_minimum_required (VERSION 3.2.1 FATAL_ERROR)

project(Maze)

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
set(CMAKE_BUILD_TYPE Debug)

include_directories(SYSTEM /usr/local/include/bullet)

find_package (Threads REQUIRED)
find_package (Bullet REQUIRED)

add_executable(mz main.cpp)

set_property(TARGET mz PROPERTY CXX_STANDARD 14)
set_property(TARGET mz PROPERTY CXX_STANDARD_REQUIRED ON)
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)

add_library(maze SHARED  maze_physics.cpp maze.cpp)
target_link_libraries (maze PRIVATE ${CMAKE_THREAD_LIBS_INIT})
target_link_libraries (mz maze ${CMAKE_THREAD_LIBS_INIT}) # PRIVATE ${BULLET_LIBRARIES})

set_property(TARGET maze PROPERTY CXX_STANDARD 14)
set_property(TARGET maze PROPERTY CXX_STANDARD_REQUIRED ON)

LINK_LIBRARIES(
  Bullet3Common
  BulletSoftBody
  BulletDynamics
  BulletCollision
  LinearMath
  OpenGLWindow
  gwen ${OPENGL_gl_LIBRARY} ${OPENGL_glu_LIBRARY}
)
