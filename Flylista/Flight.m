//
//  Flight.m
//  Flylista
//
//  Created by Dmitry Shmidt on 01.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Flight.h"


@implementation Flight

@synthesize airline;
@synthesize airlineIATA;
@synthesize beltNo;
@synthesize checkIn;
@synthesize domInt;
@synthesize flightID;
@synthesize gate;
@synthesize isArrivalNotDeparture, isAlarmSet;
@synthesize remindTime;
@synthesize scheduleTime;
@synthesize statusCode;
@synthesize statusTime;
@synthesize uniqueID;
@synthesize airportArrival, airportDeparture, airportIATAArrival, airportIATADeparture;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:airline forKey:@"airline"];
    [encoder encodeObject:airlineIATA forKey:@"airlineIATA"];
    [encoder encodeObject:airportArrival forKey:@"airportArrival"];
    [encoder encodeObject:airportIATAArrival forKey:@"airportIATAArrival"];
    [encoder encodeObject:airportDeparture forKey:@"airportDeparture"];
    [encoder encodeObject:airportIATADeparture forKey:@"airportIATADeparture"];
    [encoder encodeObject:beltNo forKey:@"beltNo"];
    [encoder encodeObject:checkIn forKey:@"checkIn"];
    [encoder encodeObject:domInt forKey:@"domInt"];
    [encoder encodeObject:flightID forKey:@"flightID"];
    [encoder encodeObject:gate forKey:@"gate"];
    [encoder encodeBool:isArrivalNotDeparture forKey:@"isArrivalNotDeparture"];
    [encoder encodeObject:remindTime forKey:@"remindTime"];
    [encoder encodeObject:scheduleTime forKey:@"scheduleTime"];
    [encoder encodeObject:statusCode forKey:@"statusCode"];
    [encoder encodeObject:statusTime forKey:@"statusTime"];
    [encoder encodeObject:uniqueID forKey:@"uniqueID"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    [self setAirline:[decoder decodeObjectForKey:@"airline"]];
    [self setAirlineIATA:[decoder decodeObjectForKey:@"airlineIATA"]];
    [self setAirportArrival:[decoder decodeObjectForKey:@"airportArrival"]];
    [self setAirportIATAArrival:[decoder decodeObjectForKey:@"airportIATAArrival"]];
    [self setAirportDeparture:[decoder decodeObjectForKey:@"airportDeparture"]];
    [self setAirportIATADeparture:[decoder decodeObjectForKey:@"airportIATADeparture"]];
    [self setBeltNo:[decoder decodeObjectForKey:@"beltNo"]];
    [self setCheckIn:[decoder decodeObjectForKey:@"checkIn"]];
    [self setDomInt:[decoder decodeObjectForKey:@"domInt"]];
    [self setFlightID:[decoder decodeObjectForKey:@"flightID"]];
    [self setGate:[decoder decodeObjectForKey:@"gate"]];
    [self setIsArrivalNotDeparture:[decoder decodeBoolForKey:@"isArrivalNotDeparture"]];
    [self setRemindTime:[decoder decodeObjectForKey:@"remindTime"]];
    [self setScheduleTime:[decoder decodeObjectForKey:@"scheduleTime"]];
    [self setStatusCode:[decoder decodeObjectForKey:@"statusCode"]];
    [self setStatusTime:[decoder decodeObjectForKey:@"statusTime"]];
    [self setUniqueID:[decoder decodeObjectForKey:@"uniqueID"]];
    
    return self;
}

@end
