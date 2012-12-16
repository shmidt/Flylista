//
//  AirportsListViewController.m
//  Flylista
//
//  Created by Dmitry Shmidt on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AirportsListViewController.h"
#import "FlightsViewController.h"

@implementation AirportsListViewController{
    NSArray *noAirports;
    NSArray *airportsNames;
//    NSArray *airportsIATAcodes;
}
@synthesize selectedAirportIATAcode = _selectedAirportIATAcode;
@synthesize delegate = _delegate;
- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void) readPList
{
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
//        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [[NSBundle mainBundle] pathForResource:@"Airports" ofType:@"plist"];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
//            [[NSFileManager defaultManager] moveItemAtPath:[[NSBundle mainBundle] pathForResource:@"Airports" ofType:@"plist"] toPath:[rootPath stringByAppendingPathComponent:@"Airports.plist"] error:nil];
////            plistPath = [[NSBundle mainBundle] pathForResource:@"noAirports" ofType:@"plist"];
//        }
    
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        noAirports = (NSArray *)[NSPropertyListSerialization
                                      propertyListWithData:plistXML options:kCFPropertyListXMLFormat_v1_0 format:&format error:nil];
        if (!noAirports) 
        {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }

    NSSortDescriptor* nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Airport" ascending:YES];
    airportsNames = [noAirports sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
    noAirports = nil;
}

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
//    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    [self readPList];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //FIXME:scroll to
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        NSString *selectedAirportIATAcode = [NSUserDefaults.standardUserDefaults stringForKey:@"selectedAirportIATAcode"];
        if (!airportsNames || selectedAirportIATAcode.length == 0) {
            return;
        }
        BOOL found = NO;
        for (NSDictionary *airportDict in airportsNames) {
            if ([airportDict[@"AirportCode"] isEqualToString:selectedAirportIATAcode]) {
                found = YES;
                NSIndexPath *ip = [NSIndexPath indexPathForRow:[airportsNames indexOfObject:airportDict] inSection:0];
                [self.tableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
        }
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return airportsNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AirportCell";
    NSLog(@"Airp cell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSDictionary *airportDict = [airportsNames objectAtIndex:indexPath.row];
    cell.textLabel.text = [airportDict objectForKey:@"Airport"];
    cell.detailTextLabel.text = [airportDict objectForKey:@"AirportCode"];
    airportDict = nil;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *airportDict = [airportsNames objectAtIndex:indexPath.row];
//    [NSUserDefaults.standardUserDefaults setObject:_selectedAirportIATAcode forKey:@"selectedAirportIATAcode"];
//    [NSUserDefaults.standardUserDefaults synchronize];
    [_delegate selectedAirport:[airportDict valueForKey:@"AirportCode"]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.parentViewController dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }

    airportDict = nil;
}

- (IBAction)cancelButtonPressed:(id)sender 
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
