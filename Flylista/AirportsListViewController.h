//
//  AirportsListViewController.h
//  Flylista
//
//  Created by Dmitry Shmidt on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectAirport <NSObject>

- (void)selectedAirport:(NSString *)selectedAirportIATACode;

@end

@interface AirportsListViewController : UITableViewController

@property (weak, nonatomic) id <SelectAirport> delegate;
@property (copy, nonatomic) NSString *selectedAirportIATAcode;

- (IBAction)cancelButtonPressed:(id)sender;
@end
