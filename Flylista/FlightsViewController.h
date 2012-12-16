//
//  MasterViewController.h
//  Flylista
//
//  Created by Dmitry Shmidt on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirportsListViewController.h"
#import "DownloadHelper.h"
#import "PullToRefreshView.h"
#import "Flight.h"
#import "GADBannerView.h"
//#import "FlightViewController.h"
@class FlightViewController;

@interface FlightsViewController : UITableViewController<DownloadHelperDelegate, GADBannerViewDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) FlightViewController *flightViewController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *airportBarButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *flightsDirectionSegmentedControl;

@property (strong, nonatomic) NSString *selectedAirportIATAcode;

@property (strong, nonatomic) AirportsListViewController *airportsListViewController;
@property(nonatomic,strong) GADBannerView *adView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)startUpdatingFlights;
- (void)downloadFlights;

- (void) parseAirlines;
- (void) parseAirports;
- (void) parseFlights;
- (void)changePrompt;

- (IBAction)changedFlightsDirection;

@end
