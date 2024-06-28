# Get the system processor architecture
if(NOT DEFINED CMAKE_SYSTEM_PROCESSOR)
  message(FATAL_ERROR "CMAKE_SYSTEM_PROCESSOR is not defined.")
endif()

# Define the architecture triplet based on the system processor
set(ARCH_TRIPLET "${CMAKE_SYSTEM_PROCESSOR}-linux-gnu")

# tracing libaries
find_library(libmock_lf_trace_plugin.a PATHS "/usr/lib/${ARCH_TRIPLET}" )
find_library(libtelegraf_lf_trace_plugin.a PATHS "/usr/lib/${ARCH_TRIPLET}" )

add_library(${LF_MAIN_TARGET}-telegraf-influx-publisher telegraf-influx-publisher.c)

target_link_libraries(${LF_MAIN_TARGET} PUBLIC
    ${LF_MAIN_TARGET}-telegraf-influx-publisher )
