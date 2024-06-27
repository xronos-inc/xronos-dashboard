// SPDX-FileCopyrightText: © 2024 Xronos Inc.
// SPDX-License-Identifier: BSD-3-Clause

#ifndef TELEGRAF_INFLUX_PUBLISHER_H
#define TELEGRAF_INFLUX_PUBLISHER_H

#pragma once

#include <netinet/in.h>
#include <arpa/inet.h>  // inet_pton()

#define INFLUXDB_MAX_LINE_LENGTH 4096
#define TAGSET_MAX_LENGTH 2048

typedef struct {
    const char * measurement;
    char tags[TAGSET_MAX_LENGTH];
    char fields[TAGSET_MAX_LENGTH];
    long long timestamp_ns;
} influxline_t;

typedef struct sockaddr_in sockaddr_in_t;

/// @brief Resolves the given hostname (or IP address) to an IPv4 address.
/// 
/// This function attempts to resolve the provided hostname to its corresponding
/// IPv4 address. If the hostname is not an IP address, it resolves the hostname
/// using the DNS. If the resolution fails, the IP address defaults to "0.0.0.0".
/// 
/// @param[in] hostname A pointer to the hostname string to be resolved.
/// @param[out] ip A pointer to a buffer where the resolved IP address will be stored.
/// @param[in] ip_len The size of the buffer provided for the IP address.
void resolve_hostname(
    char * const hostname,
    char * const ip,
    const size_t ip_len);

/// @brief Function to initialize a socket
///
/// @return The socket file descriptor. -1 if error (check errno)
int telegraf_init_socket(void);

/// @brief Function to send data using non-blocking sockets
///
/// This function sends data over a socket using non-blocking mode and monitors
/// the socket's readiness for writing using `select()`.
///
/// @param [in] sockfd The socket file descriptor
/// @param [in] server_host The server host or IP address
/// @param [in] server_port The server port
/// @param [in] data Pointer to the data to be sent
/// @param [in] data_size Size of the data to be sent in bytes
/// @return success (0) or errno on failure
int telegraf_send_data(const int sockfd,
                       const char * const server_host,
                       const int server_port,
                       const char * const data,
                       const size_t data_size);

/// @brief Append a key=value pair to a tagset, adding a comma between subsequent sets
/// @param tagset The existing tagset string
/// @param tagset_size The buffer size of the tagset string
/// @param key The key name
/// @param value The value of the key
void tagset_append(char * const tagset,
                   const size_t tagset_size,
                   const char * const key,
                   const char * const value);

/// @brief Converts an influxline structure to a string representation.
/// 
/// This function formats the data in an influxline_t structure into a string
/// representation that follows the InfluxDB line protocol.
/// 
/// @param[in] line A pointer to the influxline_t structure to be converted.
/// @param[out] outStr A pointer to the buffer where the resulting string will be stored.
/// @param[in] maxLen The maximum length of the output buffer.
/// 
/// @return The length of the formatted string, or -1 if the buffer is not large enough.
size_t influxline_to_string(const influxline_t * const line,
                            char * const outStr,
                            const size_t maxLen);


#endif // TELEGRAF_INFLUX_PUBLISHER_H