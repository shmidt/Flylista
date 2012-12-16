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

- (void)viewDidUnload
{
    NSLog(@"viewDidUnload FVC");
    _flight = nil;
    [self setAirline:nil];
    [self setTimeCrossOut:nil];
    [self setScheduleTimeLabel:nil];
    [self setAction:nil];
    [self setAlarmImageView:nil];
    [self setAlarmTime:nil];
    [self setAirportDeparture:nil];
    [self setAirportDepartureIATA:nil];
    [self setAirportArrival:nil];
    [self setAirportArrivalIATA:nil];
    [self setUpdatedTime:nil];
    [self setScheduleTime:nil];
    [self setStatus:nil];
    [self setDomInt:nil];
    [self setAlarmBarButton:nil];
    [super viewDidUnload];
}

#pragma mark - Share
//- (void)fbShare:(NSString *)text
//{
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [delegate connectToFacebook];
//    facebook =  delegate.facebook;
////    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                                   kAppId, @"app_id",
////                                   @"http://www.avinor.no/en/avinor", @"link",
//////                                   @"http://fbrell.com/f8.jpg", @"picture",
////                                   text, @"name",
////                                   @"Reference Documentation", @"caption",
////                                   @"Using Dialogs to interact with users.", @"description",
////                                   @"Facebook Dialogs are so easy!",  @"message",
////                                   nil];
////    
////    [facebook dialog:@"feed" andParams:params andDelegate:self];
//    
////    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
////                                   kAppId, @"app_id",
////                                   @"Facebook Dialogs", @"name",
////                                   @"Shut up",  @"message",
////                                   nil];
////    [facebook dialog:@"stream.publish" andParams:params andDelegate:delegate.facebook];
////    [facebook dialog:@"feed" andParams:params andDelegate:self];
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   kAppId, @"app_id",
//                                   text,  @"message",
//                                   nil];
//    [facebook requestWithGraphPath:@"/me/feed" andParams:params
//                     andHttpMethod:@"POST" andDelegate:self];
//    [SVProgressHUD show];
//    [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Sent", nil) afterDelay:2.0];
//}
- (void)tweetShare:(NSString *)shareText
{
    if (![TWTweetComposeViewController canSendTweet]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:NSLocalizedString(@"Please add twitter account into your iPhone settings.",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    TWTweetComposeViewController* twitterController = [[TWTweetComposeViewController alloc] init];
    
    [twitterController setInitialText:shareText];
    [self presentModalViewController:twitterController animated:YES];
//    [self showAd];
    //Ad here
//    self.adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
//    self.adView.autoresizingMask =
//    UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//    [self.view.window  addSubview:self.adView];
    //
    [twitterController setCompletionHandler:^(TWTweetComposeViewControllerResult result){
        // проверка результата
        [SVProgressHUD show];
        if ( result == TWTweetComposeViewControllerResultDone ) {
            [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Sent", nil) afterDelay:2.0];
            // твит отправили
        } else {
            // твит не отправили
            [SVProgressHUD dismissWithError:NSLocalizedString(@"Canceled", nil) afterDelay:2.0];
        }
//        self.adView = nil;
//        self.adView.delegate = nil;
    }];
}
- (void)smsShare:(NSString *)shareText
{
    if ([MFMessageComposeViewController canSendText]) {
        
        MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
        
        [messageComposeViewController  setBody:shareText];
        messageComposeViewController.messageComposeDelegate = self;
        
        [self.navigationController  presentModalViewController:messageComposeViewController animated:YES];
        [self showAd];
        return;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [SVProgressHUD show];
    switch (result)
    {
        case MessageComposeResultCancelled:
            [SVProgressHUD dismissWithError:NSLocalizedString(@"Canceled", nil) afterDelay:2.0];
            NSLog(@"SMS: canceled");
            break;
        case MessageComposeResultSent:
            [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Sent", nil) afterDelay:2.0];
            NSLog(@"SMS: sent");
            break;
        case MessageComposeResultFailed:
            [SVProgressHUD dismissWithError:NSLocalizedString(@"Failed", nil) afterDelay:2.0];
            NSLog(@"SMS: failed");
            break;
        default:
            [SVProgressHUD dismissWithError:NSLocalizedString(@"Not sent", nil) afterDelay:2.0];
            NSLog(@"SMS: not sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
}
- (void)emailShare:(NSString *)shareText
{
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        
        [mailComposeViewController setMessageBody:shareText isHTML:NO];
        mailComposeViewController.mailComposeDelegate = self;
        
        [self.navigationController  presentModalViewController:mailComposeViewController animated:YES];
        [self showAd];
        return;
        
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [SVProgressHUD show];

    switch (result)
    {
        case MFMailComposeResultCancelled:
            [SVProgressHUD dismissWithError:NSLocalizedString(@"Canceled", nil) afterDelay:2.0];
            NSLog(@"Mail: canceled");
            break;
        case MFMailComposeResultSent:
            [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Sent", nil) afterDelay:2.0];
            NSLog(@"Mail: sent");
            break;
        case MFMailComposeResultFailed:
            [SVProgressHUD dismissWithError:NSLocalizedString(@"Failed", nil) afterDelay:2.0];
            NSLog(@"Mail: failed");
            break;
        case MFMailComposeResultSaved:
            [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Saved", nil) afterDelay:2.0];
            NSLog(@"Mail: Saved");
            break;
        default:
            [SVProgressHUD dismissWithError:NSLocalizedString(@"Not sent", nil) afterDelay:2.0];
            NSLog(@"Mail: not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark Share Menu
- (void)showShareMenu
{
    NSString *shareText;
    shareText = [NSString stringWithFormat:NSLocalizedString(@"Flight No. %@ \"%@ — %@\" at %@ by %@.", nil), _flight.flightID, _flight.airportDeparture, _flight.airportArrival, _scheduleTime.text, _flight.airline];
    
    NSArray *items = @[shareText];
    
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activity animated:YES completion:nil];
    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:nil
//                                  delegate:self
//                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
//                                  destructiveButtonTitle:nil
//                                  otherButtonTitles:NSLocalizedString(@"Text Message", nil), NSLocalizedString(@"E-mail", nil), @"Tweet",nil];
//    
//    [actionSheet showInView:self.view];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    NSString *shareText;
    shareText = [NSString stringWithFormat:NSLocalizedString(@"Flight No. %@ \"%@ — %@\" at %@ by %@.", nil), _flight.flightID, _flight.airportDeparture, _flight.airportArrival, _scheduleTime.text, _flight.airline];
    if ([_updatedTime.text length] > 0) {
        shareText = [NSString stringWithFormat:NSLocalizedString(@"Flight No. %@ \"%@ - %@\" by %@. New time: %@.", nil),_flight.flightID, _flight.airportDeparture, _flight.airportArrival, _flight.airline,_updatedTime.text];
    }
    if ([_status.text length] > 0) {
        shareText = [NSString stringWithFormat:@"%@\n%@.",shareText, _status.text];
    } 
    else if ([_action.text length] > 0) {
        shareText = [NSString stringWithFormat:@"%@\n%@.",shareText, _action.text];
    } 
    else if ([_action.text length] > 0 && [_status.text length] > 0) {
        shareText = [NSString stringWithFormat:@"%@\n%@\n%@.",shareText, _status.text, _action.text];
    } 
    NSLog(@"Share Menu");
    if (buttonIndex == 0) {
        [self smsShare:shareText];
        
    } else if (buttonIndex == 1) {
        [self emailShare:shareText];
    }
    else if (buttonIndex == 2) {
        [self tweetShare:shareText];
    }    
//    else if (buttonIndex == 3) {
//        [self fbShare:shareText];
//    }    

	theActionSheet = nil;
    shareText = nil;
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
//        self.adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
//        self.adView.autoresizingMask =
//        UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//        [_alarmViewController.view  addSubview:self.adView];
//        [self showAd];
    }
}
#pragma mark AdWhirl

//- (void)adjustAdSize {
//    CGSize adSize = [adView actualAdSize];
//    CGRect newFrame = adView.frame;
//    newFrame.size.height = adSize.height;
//    newFrame.size.width = adSize.width;
//
//        newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
//        newFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - adSize.height;//self.view
//
//    adView.frame = newFrame;
//    adView.alpha = 0.0;
//    [UIView animateWithDuration:0.3
//                          delay:0.2
//                        options: UIViewAnimationCurveEaseOut
//                     animations:^{
//                         adView.alpha = 1.0;
//                     } 
//                     completion:^(BOOL finished){
//                         NSLog(@"Done!");
//                     }];
//}
@end
