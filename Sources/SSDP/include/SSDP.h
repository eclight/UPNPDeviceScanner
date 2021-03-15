#ifndef SSDP_h
#define SSDP_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN
                                    
@interface SSDP : NSObject

+ (BOOL)discover: (void (^)(NSString*))onDeviceDiscovered
     isCancelled: (BOOL (^)(void))isCancelled
           error: (NSError**)error;

@end

NS_ASSUME_NONNULL_END

#endif /* SSDP_h */
