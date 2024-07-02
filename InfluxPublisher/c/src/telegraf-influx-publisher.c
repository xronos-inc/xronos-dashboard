// SPDX-FileCopyrightText: © 2024 Xronos Inc.
// SPDX-License-Identifier: BSD-3-Clause

#include "telegraf-influx-publisher.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <errno.h>
#include <sys/time.h>
#include <math.h>
#include <string.h>
#include <stdbool.h>
#include <netdb.h>
#include <arpa/inet.h>
// #include <kitchensink.h>

void resolve_hostname(
    char * const hostname,
    char * const ip,
    const size_t ip_len
) {
    struct addrinfo hints;
    struct addrinfo * res = NULL;
    int status = 0;

    // Is hostname an IP address?
    struct sockaddr_in sa;
    if (inet_pton(AF_INET, hostname, &(sa.sin_addr)) > 0) {
        strncpy(ip, hostname, ip_len);
        return;
    }

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET; // Only IPv4
    hints.ai_socktype = SOCK_STREAM; // Stream socket

    status = getaddrinfo(hostname, NULL, &hints, &res);
    if (status != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(status));
        strncpy(ip, "0.0.0.0", ip_len);
        return;
    }

    struct sockaddr_in *ipv4 = (struct sockaddr_in *)res->ai_addr;
    void *addr = &(ipv4->sin_addr);

    // Convert the IP to a string
    inet_ntop(res->ai_family, addr, ip, ip_len);

    freeaddrinfo(res); // Free the linked list
}

int telegraf_init_socket(void) {
    int sockfd;
    struct sockaddr_in server_addr;

    // Create socket (SOCK_DGRAM for UDP)
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        perror("Error creating socket");
        return -1;
    }

    // set non-blocking
    int flags = fcntl(sockfd, F_GETFL, 0);
    if (flags == -1) {
        perror("Error getting socket flags");
        return errno;
    }
    if (fcntl(sockfd, F_SETFL, flags | O_NONBLOCK) == -1) {
        perror("Error setting socket to non-blocking");
        return errno;
    }

    return sockfd;
}

int telegraf_send_data(const int sockfd,
                       const char * const server_host,
                       const int server_port,
                       const char * const data,
                       const size_t data_size)
{
    ssize_t sent;
    size_t total_sent = 0;
    fd_set write_fds;
    struct timeval tv;
    struct sockaddr_in socket_addr;

    // convert the server URL to a sockaddr_in object
    memset(&socket_addr, 0, sizeof(socket_addr));
    socket_addr.sin_family = AF_INET;
    socket_addr.sin_port = htons(server_port);
    inet_pton(AF_INET, server_host, &socket_addr.sin_addr);

    while (total_sent < data_size) {
        FD_ZERO(&write_fds);
        FD_SET(sockfd, &write_fds);
        tv.tv_sec = 5; // Timeout after 5 seconds
        tv.tv_usec = 0;

        // Wait until the socket is ready to send data
        if (select(sockfd + 1, NULL, &write_fds, NULL, &tv) > 0) {
            if (FD_ISSET(sockfd, &write_fds)) {
                sent = sendto(sockfd,
                              data + total_sent,
                              data_size - total_sent,
                              0,
                              (const struct sockaddr * const)&socket_addr,
                              sizeof(socket_addr) );

                if (sent < 0) {
                    if (errno == EAGAIN || errno == EWOULDBLOCK) {
                        // The socket is not ready for sending data, try again
                        // Sleep for 10 milliseconds
                        usleep(10000); // 10 milliseconds = 10000 microseconds
                        continue;
                    }
                    perror("Error sending data");
                    return -1;
                }

                total_sent += sent;
            }
        } else {
            // select() failed or timeout occurred
            perror("Error or timeout on select()");
            return -1;
        }
    }
    return 0;
}

void tagset_append(char * const tagset,
                   const size_t tagset_size,
                   const char * const key,
                   const char * const value) {
    const size_t tagset_len = strlen(tagset);
    
    // add the tag the tagset, prepending ',' if appending
    char tag[tagset_size];
    snprintf(tag, tagset_size-1, "%s%s=%s", tagset_len > 0 ? "," : "", key, value);
    strncat(tagset, tag, tagset_size - tagset_len - 1);
}

size_t influxline_to_string(const influxline_t * const line,
                            char * const outStr,
                            const size_t maxLen
) {
    size_t len = snprintf(
        outStr,
        maxLen,
        "%s,%s %s %lld",
        line->measurement,
        line->tags, 
        line->fields,
        line->timestamp_ns);
    return len < maxLen ? len : -1; // Return -1 if the buffer is not large enough
}
