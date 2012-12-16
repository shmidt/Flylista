//
//  FlightTableViewCell.h
//  Flylista
//
//  Created by Dmitry Shmidt on 22.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlightTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *scheduleTime;
@property (strong, nonatomic) IBOutlet UILabel *airport;
@property (strong, nonatomic) IBOutlet UILabel *airline;
@property (strong, nonatomic) IBOutlet UILabel *flightNo;
@property (weak, nonatomic) IBOutlet UIImageView *statusUpdateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *alarmImageView;
@end
