
#import "SSDP.h"

@import OSLog;

#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>


static const char* SSDP_ADDRESS = "239.255.255.250";
static const int SSDP_PORT = 1900;

static const char* DISCOVER_MESSAGE =
"M-SEARCH * HTTP/1.1\r\n"
"HOST: 239.255.255.250:1900\r\n"
"MAN: \"ssdp:discover\"\r\n"
"MX: 2\r\n"
"ST: upnp:rootdevice\r\n\r\n";

static const int BUFFER_SIZE = 1024; 
static const int SOCKET_TIMEOUT = 2;
static const int RECEIVE_TIME = 5;
static const int NUM_ATTEMPTS = 3;

static NSError *nserror_from_errno() {
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
}

@implementation SSDP

+ (BOOL)discover: (void (^)(NSString*))onDeviceDiscovered
     isCancelled: (BOOL (^)(void))isCancelled
           error: (NSError**)error {

    static os_log_t log = NULL;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        log = os_log_create("com.eclight.UPNPDeviceScanner", "SSDP");
    });
    
    os_log_info(log, "SSDP discover started");
    
    *error = nil;

    int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock < 0) {
        os_log(log, "Socket creation failed: %{errno}d", errno);
        *error = nserror_from_errno();
        goto finish;
    }
    
    struct timeval timeout = {SOCKET_TIMEOUT, 0};
    int err = setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    if (err == -1) {
        os_log(log, "setsockopt failed: %{errno}d", errno);
        *error = nserror_from_errno();
        goto finish;
    }
    
    struct sockaddr_in destination_addr = {0};
    destination_addr.sin_family = AF_INET;
    destination_addr.sin_port = htons(SSDP_PORT);
    err = inet_pton(AF_INET, SSDP_ADDRESS, &destination_addr.sin_addr);
    if (err == -1) {
        os_log(log, "inet_pton failed: %{errno}d", errno);
        *error = nserror_from_errno();
        goto finish;
    }
    
    char buffer[BUFFER_SIZE];
    
    for (int attempt = 0; attempt < NUM_ATTEMPTS; attempt++) {
        if (isCancelled()) {
            goto finish;
        }
        
        long bytesSent = sendto(sock, DISCOVER_MESSAGE, strlen(DISCOVER_MESSAGE), 0, (struct sockaddr*)(&destination_addr), sizeof(destination_addr));
        
        if (bytesSent < 0) {
            os_log(log, "sendto failed: %{errno}d", errno);
            *error = nserror_from_errno();
            goto finish;
        }
        
        struct timeval start, curr, elapsed = {0, 0};
        err = gettimeofday(&start, NULL);
        if (err == -1) {
            os_log(log, "gettimeofday failed: %{errno}d", errno);
            *error = nserror_from_errno();
            goto finish;
        }
        
        while (elapsed.tv_sec < RECEIVE_TIME) {
            
            if (isCancelled()) {
                goto finish;
            }
            
            long bytes_received = recvfrom(sock, buffer, sizeof(buffer), 0, NULL, NULL);
            if (bytes_received == - 1) {
                if (errno != EAGAIN) {
                    os_log(log, "recv failed: %{errno}d", errno);
                }
            }
            else if (bytes_received > 0 && bytes_received < sizeof(buffer)) {
                NSString* response = [[NSString alloc] initWithBytes:buffer length:bytes_received encoding:NSUTF8StringEncoding];
                onDeviceDiscovered(response);
            }
            
            err = gettimeofday(&curr, NULL);
            if (err == -1) {
                os_log(log, "gettimeofday failed: %{errno}d", errno);
                *error = nserror_from_errno();
                goto finish;
            }
            timersub(&curr, &start, &elapsed);
            elapsed.tv_sec = MAX(0, elapsed.tv_sec);
            elapsed.tv_usec = MAX(0, elapsed.tv_usec);
        }
    }
    
finish:
    if (sock >= 0) {
        close(sock);
    }
    
    os_log_info(log, "SSDP discover finished");
    
    return *error == nil;
}

@end
