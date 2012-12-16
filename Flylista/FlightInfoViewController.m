//
//  FlightInfoViewController.m
//  Flylista
//
//  Created by Dmitry Shmidt on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlightInfoViewController.h"
#import "Airline.h"
#import "Airport.h"

@implementation FlightInfoViewController
@synthesize selectedFlight = _selectedFlight;
@synthesize airport = _airport;
@synthesize airportIATA = _airportIATA;
@synthesize flightID = _flightID;
@synthesize scheduleTime = _scheduleTime;
@synthesize statusTime = _statusTime;
@synthesize status = _status;
@synthesize beltNo = _beltNo;
@synthesize checkIn = _checkIn;
@synthesize gate = _gate;
@synthesize domInt = _domInt;
@synthesize arrivalOrDeparture = _arrivalOrDeparture;
@synthesize managedObjectContext = __managedObjectContext;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setAirport:nil];
    [self setAirportIATA:nil];
    [self setFlightID:nil];
    [self setScheduleTime:nil];
    [self setStatusTime:nil];
    [self setStatus:nil];
    [self setBeltNo:nil];
    [self setCheckIn:nil];
    [self setGate:nil];
    [self setArrivalOrDeparture:nil];
    [self setDomInt:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _airport.text = _selectedFlight.airport; 
    _airportIATA.text = _selectedFlight.airportIATA;
    _flightID.text = _selectedFlight.flightID;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"no_NO"];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    _scheduleTime.text = [dateFormatter stringFromDate:_selectedFlight.scheduleTime];
    _statusTime.text = [dateFormatter stringFromDate:_selectedFlight.statusTime];
    
//    _status.text = _selectedFlight.statusCode;
    _beltNo.text = _selectedFlight.beltNo;
    _checkIn.text = _selectedFlight.checkIn;
    _gate.text = _selectedFlight.gate;
    _domInt.text = _selectedFlight.domInt;
    if ([_selectedFlight.isArrivalNotDeparture boolValue]) {
        _arrivalOrDeparture.text = @"Arrival";
    } else {
        _arrivalOrDeparture.text = @"Departure";
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - DateInputTableViewCellDelegate
- (void)tableViewCell:(DateInputTableViewCell *)cell didEndEditingWithDate:(NSDate *)value {
    
	NSLog(@"%@ date changed to: %@", cell.textLabel.text, value);
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    // Configure the cell...
//    
//    return cell;
//}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Removed");
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

@end
