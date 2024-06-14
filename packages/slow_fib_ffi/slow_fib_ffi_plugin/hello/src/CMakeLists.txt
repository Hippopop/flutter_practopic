# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(hello_library VERSION 0.0.1 LANGUAGES C)

add_library(hello SHARED
  "hello.c"
)

set_target_properties(hello PROPERTIES
  PUBLIC_HEADER hello.h
  OUTPUT_NAME "hello"
)

target_compile_definitions(hello PUBLIC DART_SHARED_LIB)
