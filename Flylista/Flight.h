//
//  Flight.h
//  Flylista
//
//  Created by Dmitry Shmidt on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flight : NSObject <NSCoding>

@property (nonatomic, strong) NSString * airline;
@property (nonatomic, strong) NSString * airlineIATA;
@property (nonatomic, strong) NSString * airportArrival;
@property (nonatomic, strong) NSString * airportIATAArrival;
@property (nonatomic, strong) NSString * airportDeparture;
@property (nonatomic, strong) NSString * airportIATADeparture;
@property (nonatomic, strong) NSString * beltNo;
@property (nonatomic, strong) NSString * checkIn;
@property (nonatomic, strong) NSString * domInt;
@property (nonatomic, strong) NSString * flightID;
@property (nonatomic, strong) NSString * gate;
@property (nonatomic, assign) BOOL isArrivalNotDeparture;
@property (nonatomic, assign) BOOL isAlarmSet;
@property (nonatomic, strong) NSDate * remindTime;
@property (nonatomic, strong) NSDate * scheduleTime;
@property (nonatomic, strong) NSString * statusCode;
@property (nonatomic, strong) NSDate * statusTime;
@property (nonatomic, strong) NSString * uniqueID;

@end
