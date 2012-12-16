//
//  CustomURLConnection.h
//  Flylista
//
//  Created by Dmitry Shmidt on 03.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomURLConnection : NSURLConnection {
    NSString *tag;
}

@property (nonatomic, strong) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag;

@end
