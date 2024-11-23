# SPDX-FileCopyrightText: © 2024 Xronos Inc.
# SPDX-License-Identifier: BSD-3-Clause

# Get the system processor architecture
if(NOT DEFINED CMAKE_SYSTEM_PROCESSOR)
  message(FATAL_ERROR "CMAKE_SYSTEM_PROCESSOR is not defined.")
endif()

add_library(${LF_MAIN_TARGET}-telegraf-influx-publisher telegraf-influx-publisher.c)

target_link_libraries(${LF_MAIN_TARGET} PUBLIC
    ${LF_MAIN_TARGET}-telegraf-influx-publisher )
