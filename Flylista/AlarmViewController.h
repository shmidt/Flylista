//
//  AlarmViewController.h
//  Flylista
//
//  Created by Dmitry Shmidt on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "CoolButton.h"
#import <UIKit/UIKit.h>

@interface AlarmViewController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate *flightDate;
@property (copy, nonatomic) NSString *flightNo;
- (IBAction)changedAlarmDate:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *labelAlarm;
@property (weak, nonatomic) IBOutlet UILabel *alarmDateLabel;
- (IBAction)cancel:(id)sender;

- (IBAction)buttonPressed;
@property (weak, nonatomic) IBOutlet UILabel *buttonText;

- (void)adjustAdSize;
@property (strong, nonatomic) IBOutlet CoolButton *button;
- (void)buttonWithAlarmEnabled:(BOOL)isAlarm;
@end
