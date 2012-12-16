//
//  Airline.h
//  Flylista
//
//  Created by Dmitry Shmidt on 30.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Airline : NSObject <NSCoding>

@property (nonatomic, strong) NSString * codeIATA;
@property (nonatomic, strong) NSString * name;

@end
