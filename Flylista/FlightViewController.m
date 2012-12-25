//
//  DetailViewController.m
//  Flylista
//
//  Created by Dmitry Shmidt on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlightViewController.h"
#import "NSDate+Formatting.h"
#import <Twitter/Twitter.h>
#import "SVProgressHUD.h"

@implementation FlightViewController
@synthesize flight = _flight;
@synthesize alarmBarButton = _alarmBarButton;
@synthesize airline = _airline;
@synthesize airportDeparture = _airportDeparture;
@synthesize airportDepartureIATA = _airportDepartureIATA;
@synthesize airportArrival = _airportArrival;
@synthesize airportArrivalIATA = _airportArrivalIATA;
@synthesize updatedTime = _updatedTime;
@synthesize scheduleTime = _scheduleTime;
@synthesize status = _status;
@synthesize domInt = _domInt;
@synthesize timeCrossOut = _timeCrossOut;
@synthesize scheduleTimeLabel = _scheduleTimeLabel;
@synthesize action = _action;
@synthesize alarmViewController = _alarmViewController;
@synthesize lastUpdateDate = _lastUpdateDate;
@synthesize alarmImageView = _alarmImageView;
@synthesize alarmTime = _alarmTime;
//@synthesize facebook;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - 

- (void)updateLabels
{
    if (_lastUpdateDate) {
            self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"Last updated: %@", nil), [NSDateFormatter localizedStringFromDate:_lastUpdateDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]]; 
    }
    else
        self.navigationItem.prompt = nil;

    self.title = [NSString stringWithFormat:NSLocalizedString(@"Flight No. %@", nil), _flight.flightID];
    _airline.text = _flight.airline;
    
    _airportArrival.text = _flight.airportArrival;
    _airportArrivalIATA.text = _flight.airportIATAArrival;
    _airportDeparture.text = _flight.airportDeparture;
    _airportDepartureIATA.text = _flight.airportIATADeparture;
    
    if (_flight.isArrivalNotDeparture) {
        _scheduleTimeLabel.text = NSLocalizedString(@"Arrival Time", nil);
    } else {
        _scheduleTimeLabel.text = NSLocalizedString(@"Departure Time", nil);
    }
    _status.textColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"no_NO"];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    _scheduleTime.text = [dateFormatter stringFromDate:_flight.scheduleTime];
    if (_flight.isArrivalNotDeparture) {
        _status.text = [NSString stringWithFormat:NSLocalizedString(@"Arrival %@", nil), [_flight.scheduleTime distanceOfTimeInWords]];
    }
    else
        _status.text = [NSString stringWithFormat:NSLocalizedString(@"Departure %@", nil), [_flight.scheduleTime distanceOfTimeInWords]];
    _updatedTime.text = nil;
    
    if (_flight.statusTime) {
        if (![[dateFormatter stringFromDate:_flight.statusTime]isEqualToString:[dateFormatter stringFromDate:_flight.scheduleTime]]) {
            _updatedTime.text = [dateFormatter stringFromDate:_flight.statusTime];
            _timeCrossOut.hidden = NO;
        }
    }
    if ([_flight.statusCode isEqualToString:@"E"]) {
        if (![[dateFormatter stringFromDate:_flight.statusTime]isEqualToString:[dateFormatter stringFromDate:_flight.scheduleTime]]) {
            if (_flight.isArrivalNotDeparture) {
                _status.text = [NSString stringWithFormat:NSLocalizedString(@"Arrival %@", nil), [_flight.statusTime distanceOfTimeInWords]];
            }else
                _status.text = [NSString stringWithFormat:NSLocalizedString(@"Departure %@", nil), [_flight.statusTime distanceOfTimeInWords]];
        }
    }
    
    //	[datePicker setDate:[NSDate date]];
    if ([_flight.statusCode isEqualToString:@"C"]) {
        _timeCrossOut.hidden = NO;
        if (_flight.statusTime) {
            _status.text = [NSString stringWithFormat:NSLocalizedString(@"Cancelled %@", nil), [_flight.statusTime distanceOfTimeInWords]];
            _status.textColor = [UIColor redColor];
        }
        else
            _status.text = NSLocalizedString(@"Cancelled", nil);
    }
    if ([_flight.statusCode isEqualToString:@"A"]) {
        if (_flight.statusTime) {
            _status.text = [NSString stringWithFormat:NSLocalizedString(@"Landed %@", nil), [_flight.statusTime distanceOfTimeInWords]];
        }
        else
            _status.text = NSLocalizedString(@"Landed", nil);
    }
    if ([_flight.statusCode isEqualToString:@"D"]) {
        if (_flight.statusTime) {
            _status.text = [NSString stringWithFormat:NSLocalizedString(@"Departured %@", nil), [_flight.statusTime distanceOfTimeInWords]];
        }
        else
            _status.text = NSLocalizedString(@"Departured", nil);
    }
    if ([_flight.statusCode isEqualToString:@"N"]) {
        if (_flight.statusTime) {
            _status.text = [NSString stringWithFormat:NSLocalizedString(@"New info %@", nil), [_flight.statusTime distanceOfTimeInWords]];
        }
        else
            _status.text = NSLocalizedString(@"New info", nil);
    }
    //Flight type
    if ([_flight.domInt isEqualToString:@"D"]) {
        _domInt.text = NSLocalizedString(@"Domestic", nil);
    } 
    else if ([_flight.domInt isEqualToString:@"S"])
    {
        _domInt.text = NSLocalizedString(@"Schengen", nil);
    }
    else if ([_flight.domInt isEqualToString:@"I"])
    {
        _domInt.text = NSLocalizedString(@"International", nil);
    }
    _action.text = nil;
    if ([_flight.beltNo length] > 0) {
        _action.text = [NSString stringWithFormat:NSLocalizedString(@"Belt No. %@", nil), _flight.beltNo];
    }
    if ([_flight.checkIn length] > 0) {
        _action.text = [NSString stringWithFormat:NSLocalizedString(@"Check In %@", nil), _flight.checkIn];
    }
    if ([_flight.gate length] > 0) {
        _action.text = [NSString stringWithFormat:NSLocalizedString(@"Gate No. %@", nil), _flight.gate];
    }
    
    for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) 
    {
        if ([[lNotification.userInfo valueForKey:@"FlightUniqueIDKey"] isEqualToString:_flight.flightID]) 
        {
            _alarmTime.hidden = NO;
            _alarmTime.text = [dateFormatter stringFromDate:lNotification.fireDate];
            _alarmImageView.hidden = NO;
        }
    }

    //Additional info
    
    //    if (flight.status){
    //        if ([flight.status isEqualToString:@"A"]) {
    //            [(UILabel *)[cell viewWithTag:6] setText: [NSString stringWithFormat: @"Landet %@", newTimeStr]];			
    //        }
    //        else if ([flight.status isEqualToString:@"D"]) {
    //            [(UILabel *)[cell viewWithTag:6] setText: [NSString stringWithFormat: @"Avreist %@", newTimeStr]];	
    //        }
    //        else if ([flight.status isEqualToString:@"C"]) {
    //            [(UILabel *)[cell viewWithTag:6] setText: [NSString stringWithFormat: @"INNSTILT"]];
    //        }
    //        
    //        else if ([flight.status isEqualToString:@"E"]) {
    //            [(UILabel *)[cell viewWithTag:6] setText: [NSString stringWithFormat: @"New time %@", newTimeStr]];
    //        }
    //        else if ([flight.status isEqualToString:@"N"]) {
    //            [(UILabel *)[cell viewWithTag:6] setText: [NSString stringWithFormat: @"New info %@", newTimeStr]];
    //        }
    //    }

}
#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([_flight.statusTime timeIntervalSinceNow] < 0) {
        _alarmBarButton.enabled = NO;
        NSLog(@"flight.statusTime timeIntervalSinceNow");
    }
    [self updateLabels];       
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//- (IBAction) reloadFlightInfo
//{
//    FlightsViewController *flightsViewController = [[FlightsViewController alloc]init];
//    [flightsViewController performSelector:@selector(downloadFlights)];
//}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Oslo"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light_wool"]];
    _airline.shadowColor = [UIColor whiteColor];
    _airline.shadowOffset = CGSizeMake(0, 1);
    _airportArrival.shadowColor = [UIColor whiteColor];
    _airportArrival.shadowOffset = CGSizeMake(0, 1);
    _airportArrivalIATA.shadowColor = [UIColor whiteColor];
    _airportArrivalIATA.shadowOffset = CGSizeMake(0, 1);
    _airportDeparture.shadowColor = [UIColor whiteColor];
    _airportDeparture.shadowOffset = CGSizeMake(0, 1);
    _airportDepartureIATA.shadowColor = [UIColor whiteColor];
    _airportDepartureIATA.shadowOffset = CGSizeMake(0, 1);
    _scheduleTime.shadowColor = [UIColor whiteColor];
    _scheduleTime.shadowOffset = CGSizeMake(0, 1);
    _updatedTime.shadowColor = [UIColor whiteColor];
    _updatedTime.shadowOffset = CGSizeMake(0, 1);
    _action.shadowColor = [UIColor whiteColor];
    _action.shadowOffset = CGSizeMake(0, 1);
    _domInt.shadowColor = [UIColor whiteColor];
    _domInt.shadowOffset = CGSizeMake(0, 1);
    _status.shadowColor = [UIColor whiteColor];
    _status.shadowOffset = CGSizeMake(0, 1);
    self.trackedViewName = @"Flight View Screen";
NSLog(@"%s",__PRETTY_FUNCTION__);
    
}
#pragma mark Share Menu
- (void)showShareMenu
{
    NSString *shareText;
    shareText = [NSString stringWithFormat:NSLocalizedString(@"Flight No. %@ \"%@ — %@\" at %@ by %@.", nil), _flight.flightID, _flight.airportDeparture, _flight.airportArrival, _scheduleTime.text, _flight.airline];
    
    NSArray *items = @[shareText];
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activity animated:YES completion:nil];
}
#pragma mark Share Menu
- (IBAction)shareFlightInfo 
{
    [self showShareMenu];
}
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showFlightAlarm"]) {
        _alarmViewController = [segue destinationViewController];
        _alarmViewController.flightNo = _flight.flightID;
        _alarmViewController.flightDate = _flight.scheduleTime;
    }
}
@end
