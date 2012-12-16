//
//  FlightInfoViewController.h
//  Flylista
//
//  Created by Dmitry Shmidt on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateInputTableViewCell.h"
#import "Flight.h"

@interface FlightInfoViewController : UITableViewController<DateInputTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *airport;
@property (weak, nonatomic) IBOutlet UILabel *airportIATA;
@property (weak, nonatomic) IBOutlet UILabel *flightID;
@property (weak, nonatomic) IBOutlet UILabel *scheduleTime;
@property (weak, nonatomic) IBOutlet UILabel *statusTime;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *beltNo;
@property (weak, nonatomic) IBOutlet UILabel *checkIn;
@property (weak, nonatomic) IBOutlet UILabel *gate;
@property (weak, nonatomic) IBOutlet UILabel *domInt;
@property (weak, nonatomic) IBOutlet UILabel *arrivalOrDeparture;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Flight *selectedFlight;
@end
