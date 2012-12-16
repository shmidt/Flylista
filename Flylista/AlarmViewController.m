//
//  AlarmViewController.m
//  Flylista
//
//  Created by Dmitry Shmidt on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AlarmViewController.h"
#import "NSDate+Formatting.h"
//#import "SVProgressHUD.h"

@implementation AlarmViewController{
    BOOL alarm;
}
@synthesize buttonText;
@synthesize button;
@synthesize labelAlarm;
@synthesize alarmDateLabel;
@synthesize datePicker;
@synthesize flightDate, flightNo;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) 
    {
        if ([[lNotification.userInfo valueForKey:@"FlightUniqueIDKey"] isEqualToString:flightNo]) 
        {
            button.hue = 0.0;
            button.saturation = 0.8;
            button.brightness = 0.84;
            alarm = YES;
            buttonText.text = NSLocalizedString(@"Stop", nil);
//            break;
            return;
        }
        
    }
    button.hue = 0.32;
    button.saturation = 0.8;
    button.brightness = 0.69;
    buttonText.text = NSLocalizedString(@"Start", nil);
    self.trackedViewName = @"Alarm Screen View";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    datePicker.countDownDuration = [flightDate timeIntervalSinceNow] - 4*60.0f;
    for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) 
    {
        if ([[lNotification.userInfo valueForKey:@"FlightUniqueIDKey"] isEqualToString:flightNo]) 
        {
            datePicker.countDownDuration = [flightDate timeIntervalSinceDate:lNotification.fireDate];
        }
    }
    [self changedAlarmDate:nil];
}

- (void)viewDidUnload
{

    [self setDatePicker:nil];
    [self setTitle:nil];
    [self setLabelAlarm:nil];
    [self setAlarmDateLabel:nil];
//    [self setBanner:nil];
    [self setButton:nil];
    [self setButtonText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark Notification
- (void)scheduleNotification {
    for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) 
    {
        if ([[lNotification.userInfo valueForKey:@"FlightUniqueIDKey"] isEqualToString:flightNo]) 
        {
           [[UIApplication sharedApplication] cancelLocalNotification:lNotification];
        }
    }
    
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    
    if (localNotif == nil)
        return;

    NSTimeInterval secondsBefore = (NSTimeInterval)datePicker.countDownDuration;

    NSDate *fireDate = [flightDate dateByAddingTimeInterval:-(secondsBefore)];
    if ([fireDate timeIntervalSinceNow] < 10.0f)
    {
        datePicker.countDownDuration = [flightDate timeIntervalSinceNow] - 4*60.0f;
        secondsBefore = [flightDate timeIntervalSinceNow] - 4*60.0f;
    }
//    localNotif.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Oslo"];
    localNotif.fireDate = [flightDate dateByAddingTimeInterval:-(secondsBefore)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"no_NO"];
    
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Flight No.%@ %@.", nil),
                            flightNo, [flightDate distanceOfTimeInWords:localNotif.fireDate]];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
//    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:flightNo forKey:@"FlightUniqueIDKey"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//    [SVProgressHUD show];
//    [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"Alarm set", nil) afterDelay:2.0];
//    NSLog([[[UIApplication sharedApplication] scheduledLocalNotifications]description]);
}

- (IBAction)changedAlarmDate:(id)sender {
    NSTimeInterval secondsBefore = (NSTimeInterval)datePicker.countDownDuration;
    
    NSDate *fireDate = [flightDate dateByAddingTimeInterval:-(secondsBefore)];
    
    if ([fireDate timeIntervalSinceNow] < 4*60.0f)
    {
        datePicker.countDownDuration = [flightDate timeIntervalSinceNow] - 3*60.0f;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"no_NO"];
    alarmDateLabel.text = [dateFormatter stringFromDate:fireDate];
    labelAlarm.text = [NSString stringWithFormat:NSLocalizedString(@"Alarm %@", nil), [fireDate distanceOfTimeInWords]];
}
                  
- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)buttonWithAlarmEnabled:(BOOL)isAlarm{
    if (isAlarm) 
    {
        button.hue = 0.0;
        button.saturation = 0.8;
        button.brightness = 0.84;
        alarm = YES;
        buttonText.text = @"Stop";
        [self scheduleNotification];
    }else
    {
        button.hue = 0.32;
        button.saturation = 0.8;
        button.brightness = 0.69;
        buttonText.text = @"Start";
        for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) 
        {
            if ([[lNotification.userInfo valueForKey:@"FlightUniqueIDKey"] isEqualToString:flightNo]) 
            {
                [[UIApplication sharedApplication] cancelLocalNotification:lNotification];
            }
        }
        alarm = NO;
//        [SVProgressHUD show];
//        [SVProgressHUD dismissWithError:NSLocalizedString(@"Alarm stopped", nil) afterDelay:2.0];
    }
}
- (IBAction)buttonPressed {
    [self buttonWithAlarmEnabled:!alarm];
    [self performSelector:@selector(cancel:) withObject:nil afterDelay:0.7];
}
#pragma mark AdWhirl
- (NSString *)adWhirlApplicationKey {
    return @"6cb396e67e32496c841a70bc762ee093";
}
//
- (BOOL)adWhirlTestMode {
    return NO;
}
//
- (void)adWhirlDidDismissFullScreenModal
{
    NSLog(@"adWhirlDidDismissFullScreenModal");
}
//
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}
//
//- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView {
//    [self adjustAdSize];
//}
//
//- (void)adjustAdSize {
//    
//    [UIView beginAnimations:@"AdResize" context:nil];
//    [UIView setAnimationDuration:0.7];
//    CGSize adSize = [adView actualAdSize];
//    CGRect newFrame = adView.frame;
//    newFrame.size.height = adSize.height;
//    newFrame.size.width = adSize.width;
//    newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
//    newFrame.origin.y = self.view.bounds.size.height - adSize.height;
//    adView.frame = newFrame;
//    [UIView commitAnimations];
//}
@end
