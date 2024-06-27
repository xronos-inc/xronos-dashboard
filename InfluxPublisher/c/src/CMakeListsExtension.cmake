add_library(${LF_MAIN_TARGET}-telegraf-influx-publisher telegraf-influx-publisher.c)

target_link_libraries(${LF_MAIN_TARGET} PUBLIC
    ${LF_MAIN_TARGET}-telegraf-influx-publisher )
