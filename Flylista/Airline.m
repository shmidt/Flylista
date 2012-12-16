//
//  Airline.m
//  Flylista
//
//  Created by Dmitry Shmidt on 30.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Airline.h"


@implementation Airline

@synthesize codeIATA;
@synthesize name;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:codeIATA forKey:@"codeIATA"];
    [encoder encodeObject:name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    [self setCodeIATA:[decoder decodeObjectForKey:@"codeIATA"]];
    [self setName:[decoder decodeObjectForKey:@"name"]];
    
    return self;
}

@end
