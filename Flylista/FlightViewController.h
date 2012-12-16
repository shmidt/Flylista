//
//  DetailViewController.h
//  Flylista
//
//  Created by Dmitry Shmidt on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flight.h"
#import <MessageUI/MessageUI.h>
#import "AlarmViewController.h"

@interface FlightViewController : GAITrackedViewController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *alarmBarButton;
@property (weak, nonatomic) IBOutlet UILabel *airline;
@property (strong, nonatomic) IBOutlet UILabel *airportDeparture;
@property (strong, nonatomic) IBOutlet UILabel *airportDepartureIATA;
@property (strong, nonatomic) IBOutlet UILabel *airportArrival;
@property (strong, nonatomic) IBOutlet UILabel *airportArrivalIATA;
@property (weak, nonatomic) IBOutlet UILabel *updatedTime;
@property (weak, nonatomic) IBOutlet UILabel *scheduleTime;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *domInt;
@property (weak, nonatomic) IBOutlet UIImageView *timeCrossOut;
@property (weak, nonatomic) IBOutlet UILabel *scheduleTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *action;
@property (strong, nonatomic) Flight *flight;
@property (strong, nonatomic) NSDate *lastUpdateDate;
@property (weak, nonatomic) IBOutlet UIImageView *alarmImageView;
@property (weak, nonatomic) IBOutlet UILabel *alarmTime;

@property (strong, nonatomic) AlarmViewController *alarmViewController;
//@property (nonatomic, strong) Facebook *facebook;

- (IBAction)updateLabels;
- (IBAction)shareFlightInfo;
- (void)adjustAdSize;
- (void)showAd;

@end
