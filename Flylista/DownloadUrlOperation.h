//
//  DownloadUrlOperation.h
//  OperationsDemo
//
//  Created by Ankit Gupta on 6/6/11.
//  Copyright 2011 Pulse News. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DownloadUrlOperation : NSOperation {
    // In concurrent operations, we have to manage the operation's state
    BOOL executing_;
    BOOL finished_;
    
    // The actual NSURLConnection management
    NSURL*    connectionURL_;
    NSURLConnection*  connection_;
    NSMutableData*    data_;
}

@property (nonatomic, strong, readonly) NSError* error;
@property (nonatomic, strong, readonly) NSMutableData *data;
@property (nonatomic, strong, readonly) NSURL *connectionURL;

- (id)initWithURL:(NSURL*)url;

@end
