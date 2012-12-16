//
//  CustomURLConnection.m
//  Flylista
//
//  Created by Dmitry Shmidt on 03.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomURLConnection.h"

@implementation CustomURLConnection

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag {
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    
    if (self) {
        self.tag = tag;
    }
    return self;
}

@end
