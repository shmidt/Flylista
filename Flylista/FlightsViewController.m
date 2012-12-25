//
//  MasterViewController.m
//  Flylista
//
//  Created by Dmitry Shmidt on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlightsViewController.h"
#import "FlightTableViewCell.h"
#import "FlightViewController.h"
#import "SMXMLDocument.h"
#import "DownloadUrlOperation.h"
#import "NSDate+Formatting.h"
#import "Reachability.h"
#import "GradientView.h"

#define DEST_PATH   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/FlightsDB.xml"]
#define AIRLINES_PATH   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/AirlinesDB.xml"]
#define AIRPORTS_PATH   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/AirportsDB.xml"]
#define FLIGHTS_NOTIFY_PATH   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/FlightsNotify.xml"]


@implementation FlightsViewController{
    NSMutableString *flightsURLStr;
    
    NSMutableDictionary *airlines;
    NSMutableDictionary *airports;
    NSMutableArray *flights;
    NSMutableDictionary *sections;
    NSMutableArray *sortedDates;
    
    NSData *flightsData;
    NSData *airlinesData;
    NSData *airportsData;
    
    NSTimer *repeatingTimer;
    float updatingInterval;
    
    int timeFromInHours;
    int timeToInHours;
    
    NSDate *selectedDate;
    int *selectedDirection;
    NSUserDefaults *userDefaults;
    //
    NSMutableDictionary *websites;
    NSMutableArray *operations;
    NSOperationQueue *operationQueue;
    DownloadHelper *helper;
    //    MBProgressHUD *HUD;
    PullToRefreshView *pull;
    UIPopoverController *masterPopoverController;
    //    UIActivityIndicatorView *activityIndicatorView;
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 900.0);
        //        self.
    }
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    pull = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"AirlinesDB"])
        [[NSFileManager defaultManager] moveItemAtPath:@"AirlinesDB" toPath:AIRLINES_PATH error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"AirportsDB"])
        [[NSFileManager defaultManager] moveItemAtPath:@"AirportsDB" toPath:AIRPORTS_PATH error:nil];
    
    airlines = [NSMutableDictionary dictionaryWithContentsOfFile:AIRLINES_PATH];
    airports = [NSMutableDictionary dictionaryWithContentsOfFile:AIRPORTS_PATH];
    
    websites = [NSMutableDictionary dictionary];
    
    if ([airlines count] == 0) {
        NSLog(@"NO FILE WITH AIRLINES");
        [websites setValue:@"http://flydata.avinor.no/airlineNames.asp" forKey:@"Airlines"];
    }
    if ([airports count] == 0) {
        NSLog(@"NO FILE WITH AIRPORTS");
        [websites setValue:@"http://flydata.avinor.no/airportNames.asp?" forKey:@"Airports"];
    }
    if ([websites count] > 0) {
        // Create operation queue
        operationQueue = [NSOperationQueue new];
        // set maximum operations possible
        [operationQueue setMaxConcurrentOperationCount:1];
    }    
    // Add operations to download data
    operations = [NSMutableArray array];
    for (int i = 0; i < [[websites allKeys] count]; i++) {
        NSString *key  = [[websites allKeys] objectAtIndex:i];
        NSString *urlAsString = [websites valueForKey:key];
        DownloadUrlOperation *operation = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:urlAsString]];
        //        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
        [operations addObject:operation];
        [operationQueue addOperation:operation]; // operation starts as soon as its added
    }   
    //My
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    _selectedAirportIATAcode = [userDefaults stringForKey:@"selectedAirportIATAcode"];
    updatingInterval = [userDefaults floatForKey:@"updatingInterval"];    
    if (updatingInterval == 0) 
    {
        updatingInterval = 3*60.0;
    }
    
    //    updatingInterval = 1*10.0;
    NSNumber *timeFromInHoursDef = [userDefaults objectForKey:@"timeFromInHours"];
    timeFromInHours = [timeFromInHoursDef intValue];
    
    NSNumber *timeToInHoursDef = [userDefaults objectForKey:@"timeToInHours"];
    timeToInHours = [timeToInHoursDef intValue];
    [self startUpdatingFlights];
    self.tableView.backgroundView = [[GradientView alloc] init];
    
//    self.adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner ];

    
    GADAdSize adSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        adSize = kGADAdSizeBanner;
    }else {
        adSize = kGADAdSizeLeaderboard;
    }
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height + 20 -
                                 CGSizeFromGADAdSize(adSize).height);
    self.adView = [[GADBannerView alloc] initWithAdSize:adSize origin:origin];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    self.adView.adUnitID = @"3688b63dba794954";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    self.adView.rootViewController = self;
    [self.navigationController.view addSubview:self.adView];
    _adView.delegate = self;
    // Initiate a generic request to load it with an ad.
    [self.adView loadRequest:[GADRequest request]];
    //    self.tableView.backgroundColor = [UIColor underPageBackgroundColor];
    //    self.tableView.backgroundColor = [UIColor colorWithRed:227/255.0 green:228/255.0 blue:229/255.0 alpha:1.0];
    //    NSLog([[NSTimeZone knownTimeZoneNames]description]);
    //    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Oslo"]];
}

- (void)viewDidUnload
{
    NSLog(@"viewDidUnload");
    [repeatingTimer invalidate];
    
    [self setFlightsDirectionSegmentedControl:nil];
    [self setAirportBarButton:nil];
    airlines = nil;
    airports = nil;
    _selectedAirportIATAcode = nil;
    [super viewDidUnload];
}
- (void)adViewDidReceiveAd:(GADBannerView *)view{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)showAirports
{
    [self performSegueWithIdentifier:@"showAirports" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _flightsDirectionSegmentedControl.selectedSegmentIndex = [userDefaults integerForKey:@"selectedDirection"];
    
    if ([_selectedAirportIATAcode length] > 0) {
        self.navigationItem.leftBarButtonItem.title = _selectedAirportIATAcode;
        self.navigationItem.leftBarButtonItem.title = [airports objectForKey:_selectedAirportIATAcode];
        NSLog(_selectedAirportIATAcode);
    }else {
        _selectedAirportIATAcode = @"OSL";
        self.navigationItem.leftBarButtonItem.title = @"Oslo";
    }
    Reachability *reach = [Reachability reachabilityForInternetConnection];	
    NetworkStatus netStatus = [reach currentReachabilityStatus];    
    if (netStatus == NotReachable) {        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No internet connection!", nil) message:NSLocalizedString(@"Please check network settings", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else
    {
        [self downloadFlights];
    }
    
    [self changePrompt];
    self.adView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.adView.hidden = YES;
    [userDefaults setObject:_selectedAirportIATAcode forKey:@"selectedAirportIATAcode"];
    [userDefaults setFloat:updatingInterval forKey:@"updatingInterval"];
    [userDefaults setObject:[NSNumber numberWithInt:timeFromInHours] forKey:@"timeFromInHours"];
    [userDefaults setObject:[NSNumber numberWithInt:timeToInHours] forKey:@"timeToInHours"];
    [userDefaults setInteger:_flightsDirectionSegmentedControl.selectedSegmentIndex forKey:@"selectedDirection"];
    [userDefaults synchronize];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    });
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark - Table
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sortedDates count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sortedDates objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[sections objectForKey:[sortedDates objectAtIndex:section]] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FlightCell";    
    FlightTableViewCell *cell = (FlightTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    /* Get the CustomObject for the row */
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}
//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    CustomHeader *header = [[CustomHeader alloc] init];        
//    header.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
////    if (section == 1) {
//        header.lightColor = [UIColor colorWithRed:147.0/255.0 green:105.0/255.0 blue:216.0/255.0 alpha:1.0];
//        header.darkColor = [UIColor colorWithRed:72.0/255.0 green:22.0/255.0 blue:137.0/255.0 alpha:1.0];
////    }
//    return header;
//}
#pragma mark -
- (void)configureCell:(FlightTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundView = [[GradientView alloc] init];
    
    NSString * countryName = [sortedDates objectAtIndex:indexPath.section];
    NSArray * objectsForCountry = [sections objectForKey:countryName];
    Flight * flightRecord = [objectsForCountry objectAtIndex:indexPath.row];
    
    //       Flight * flightRecord = [flights objectAtIndex:indexPath.row];
    if (_flightsDirectionSegmentedControl.selectedSegmentIndex == 0) 
        cell.airport.text = flightRecord.airportArrival;
    else
        cell.airport.text = flightRecord.airportDeparture;
    //    }
    
    cell.flightNo.text = flightRecord.flightID;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"no_NO"];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    cell.scheduleTime.text = [dateFormatter stringFromDate:flightRecord.scheduleTime];
    
    if ([flightRecord.statusCode isEqualToString:@"A"] || [flightRecord.statusCode isEqualToString:@"D"] || [flightRecord.statusCode isEqualToString:@"N"] || [flightRecord.statusCode isEqualToString:@"C"] || [flightRecord.statusCode isEqualToString:@"E"]) {
        cell.statusUpdateImageView.hidden = NO;
    }
    
    cell.airline.text = flightRecord.airline;
    if (flightRecord.isAlarmSet) {
        cell.airport.alpha = 1.0;
        cell.airline.alpha = 1.0;
        [UIView animateWithDuration:0.7
                              delay:0 
                            options:UIViewAnimationOptionAllowUserInteraction |
         UIViewAnimationOptionAutoreverse |
         UIViewAnimationOptionRepeat
                         animations:^{
                             cell.airport.alpha = 0.5;
                             cell.airline.alpha = 0.5;
                         } 
                         completion:nil];
        cell.alarmImageView.hidden = NO;
    } else {
        cell.alarmImageView.hidden = YES;
        cell.airport.alpha = 1.0;
        cell.airline.alpha = 1.0;
    }
    //    cell.airport.shadowColor = [UIColor whiteColor];
    //    cell.airport.shadowOffset = CGSizeMake(1, -1);
    //    cell.airline.shadowColor = [UIColor whiteColor];
    //    cell.airline.shadowOffset = CGSizeMake(1, -1);
    //    cell.flightNo.shadowColor = [UIColor whiteColor];
    //    cell.flightNo.shadowOffset = CGSizeMake(1, -1);
    //    cell.scheduleTime.shadowColor = [UIColor whiteColor];
    //    cell.scheduleTime.shadowOffset = CGSizeMake(1, -1);
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showFlight"]) {
        _flightViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray *flightsInSection = [sections objectForKey:[sortedDates objectAtIndex:indexPath.section]];
        _flightViewController.flight = [flightsInSection objectAtIndex:indexPath.row];
        
    }
    if ([[segue identifier] isEqualToString:@"showAirports"]) {
        _airportsListViewController = (AirportsListViewController *)[[segue destinationViewController] topViewController];
        _airportsListViewController.delegate = self;
    }
}

#pragma mark - selectedAirport Delegate
- (void)changePrompt
{
    NSString *selectedAirportFullName = [airports objectForKey:_selectedAirportIATAcode];
    if ([selectedAirportFullName length] == 0){
        selectedAirportFullName = @"Oslo";
    }
    if (_flightsDirectionSegmentedControl.selectedSegmentIndex == 0) {
        self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"Arrivals to %@", nil) , selectedAirportFullName];
    }
    else
        self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"Departures from %@", nil), selectedAirportFullName];
}

- (void)selectedAirport:(NSString *)selectedAirportIATACode
{
    _selectedAirportIATAcode = selectedAirportIATACode;
    self.navigationItem.leftBarButtonItem.title = [airports objectForKey:_selectedAirportIATAcode];
    
    [self changePrompt];
    //    [self.tableView reloadData];
    [self downloadFlights];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//    } else {
//        return YES;
//    }
//}
#pragma mark - Update

- (IBAction)changedFlightsDirection {
    [self changePrompt];
    
    [self downloadFlights];
}
- (void)startUpdatingFlights
{
    repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:updatingInterval target:self selector:@selector(downloadFlights) userInfo:nil repeats:YES];
    [repeatingTimer fire];
}
#pragma mark KVO - Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)operation change:(NSDictionary *)change context:(void *)context {
    NSString *source = nil;
    NSData *data = nil;
    NSError *error = nil;
    if ([operation isKindOfClass:[DownloadUrlOperation class]]) {
        DownloadUrlOperation *downloadOperation = (DownloadUrlOperation *)operation;
        for (NSString *key in [websites allKeys]) {
            if ([[websites valueForKey:key] isEqualToString:[downloadOperation.connectionURL absoluteString]]) {
                source = key;
                break;
            }
        }
        if (source) {
            data = [downloadOperation data];
            error = [downloadOperation error];
        }
    }
    if (source) {
        NSLog(@"Downloaded finished from %@", source);
        if (error != nil) {
            // handle error
            // Notify that we have got an error downloading this data;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataDownloadFailed"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:source, @"source", error, @"error", nil]]; 
            
        } else {
            // Notify that we have got this source data;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataDownloadFinished"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:source, @"source", data, @"data", nil]]; 
            // save data
            if ([source isEqualToString:@"Airports"]) {
                airportsData = [NSData dataWithData:data];
                [websites removeObjectForKey:@"Airports"];
                //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self parseAirports];
                //                });
                
            } else if ([source isEqualToString:@"Airlines"]){
                [websites removeObjectForKey:@"Airlines"];
                airlinesData = [NSData dataWithData:data];
                //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self parseAirlines];
                //                });
                
            } 
        }
    }
}
#pragma mark -
- (void) downloadFinished
{
    [self parseFlights];
}

- (void) dataDownloadFailed: (NSString *) reason
{
    //    self.title = @"Download Failed";
}

- (void) downloadReceivedData
{
    //    float received = helper.bytesRead;
    //    float expected = helper.expectedLength;
    //    HUD.progress = helper.bytesRead/helper.expectedLength;
    //NEED TO IMPLEMENT
}

#pragma mark - Download
- (void)downloadFlights
{
    NSString *directionStr;
    if (_flightsDirectionSegmentedControl.selectedSegmentIndex == 0) {
        directionStr = @"A";
    }
    else
        directionStr = @"D";
    
    flightsURLStr = [NSString stringWithFormat:@"http://flydata.avinor.no/XmlFeed.asp?TimeFrom=%i&TimeTo=%i&airport=%@&direction=%@",timeFromInHours, timeToInHours, _selectedAirportIATAcode, directionStr];
    NSLog(flightsURLStr);
    // Remove any existing data
    if ([[NSFileManager defaultManager] fileExistsAtPath:DEST_PATH])
        [[NSFileManager defaultManager] removeItemAtPath:DEST_PATH error:nil];
    
    helper = [DownloadHelper download:flightsURLStr withTargetPath:DEST_PATH withDelegate:self];
    flightsURLStr = nil;
    directionStr = nil;
    //    [self parseFlights];
}
#pragma mark - Parsing XML
- (void) parseAirlines
{
    airlines = [NSMutableDictionary dictionary];
    SMXMLDocument *document = [SMXMLDocument documentWithData:airlinesData error:NULL];
    //    NSLog(document.root);
    for (SMXMLElement *airlineXML in [document.root childrenNamed:@"airlineName"]) {
        [airlines setObject:[airlineXML attributeNamed:@"name"] forKey:[airlineXML attributeNamed:@"code"]];		
    }
    
    NSLog(@"Parsed airlines: %i", [airlines count]);
    if ([[NSFileManager defaultManager] fileExistsAtPath:AIRLINES_PATH])
        [[NSFileManager defaultManager] removeItemAtPath:AIRLINES_PATH error:nil];
    [airlines writeToFile:AIRLINES_PATH atomically:NO];
    [self parseFlights];
    airlinesData = nil;
}

- (void) parseAirports
{
    airports = [NSMutableDictionary dictionary];
    SMXMLDocument *document = [SMXMLDocument documentWithData:airportsData error:NULL];
    for (SMXMLElement *airportXML in [document.root childrenNamed:@"airportName"]) {
        [airports setObject:[airportXML attributeNamed:@"name"] forKey:[airportXML attributeNamed:@"code"]];
    }
    NSLog(@"Parsed airports: %i", [airports count]);
    airportsData = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:AIRPORTS_PATH])
        [[NSFileManager defaultManager] removeItemAtPath:AIRPORTS_PATH error:nil];
    [airports writeToFile:AIRPORTS_PATH atomically:NO];
    [self parseFlights];
}

- (void) parseFlights
{
    NSLog(@"parseFlights");
    
    flights = [NSMutableArray array];
    
    flightsData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:DEST_PATH]];
    SMXMLDocument *document = [SMXMLDocument documentWithData:flightsData error:NULL];
    //    NSLog([document.root description]);
    // Pull out the <books> node
	SMXMLElement *flightsXML = [document.root childNamed:@"flights"];
	// Look through <books> children of type <book>
	for (SMXMLElement *flightXML in [flightsXML childrenNamed:@"flight"]) {
        Flight *flightNew = [[Flight alloc]init];
        
        // demonstrate common cases of extracting XML data
        flightNew.uniqueID = [flightXML attributeNamed:@"uniqueID"];
        flightNew.airlineIATA = [flightXML valueWithPath:@"airline"];
        flightNew.airline = [airlines objectForKey:flightNew.airlineIATA];
        flightNew.flightID = [flightXML valueWithPath:@"flight_id"];
        for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) 
        {
            if ([[lNotification.userInfo valueForKey:@"FlightUniqueIDKey"] isEqualToString:flightNew.flightID]) 
            {
                flightNew.isAlarmSet = YES;
            }
        }
        flightNew.domInt = [flightXML valueWithPath:@"dom_int"];
        flightNew.checkIn = [flightXML valueWithPath:@"check_in"]; 
        flightNew.gate = [flightXML valueWithPath:@"gate"];
        NSString * arrDep = [flightXML valueWithPath:@"arr_dep"];
        if ([arrDep isEqualToString:@"A"]) {
            flightNew.isArrivalNotDeparture = YES;
            flightNew.airportIATAArrival = [flightXML valueWithPath:@"airport"];
            flightNew.airportArrival = [airports objectForKey:flightNew.airportIATAArrival];
            flightNew.airportIATADeparture = _selectedAirportIATAcode;
            flightNew.airportDeparture = [airports objectForKey:_selectedAirportIATAcode];
        } else if ([arrDep isEqualToString:@"D"])
        {
            flightNew.isArrivalNotDeparture = NO;
            flightNew.airportIATADeparture = [flightXML valueWithPath:@"airport"];
            flightNew.airportDeparture = [airports objectForKey:flightNew.airportIATADeparture];
            flightNew.airportIATAArrival = _selectedAirportIATAcode;
            flightNew.airportArrival = [airports objectForKey:_selectedAirportIATAcode];
        }
        NSDateFormatter *xmlDateFormatter = [[NSDateFormatter alloc] init];
        [xmlDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [xmlDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
        
        flightNew.scheduleTime = [xmlDateFormatter dateFromString:[flightXML valueWithPath:@"schedule_time"]];
        flightNew.statusTime = [xmlDateFormatter dateFromString:[[flightXML childNamed:@"status"] attributeNamed:@"time"]];
        [xmlDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"no_NO"]];
        
        flightNew.statusCode = [[flightXML childNamed:@"status"] attributeNamed:@"code"];
        flightNew.beltNo = [flightXML valueWithPath:@"belt_number"];
        
        [flights addObject:flightNew];
        
        if (_flightViewController) 
        {
            if ([_flightViewController.flight.uniqueID isEqualToString:flightNew.uniqueID]) {
                _flightViewController.flight = flightNew;
                NSDate *lastUpdateDate = [xmlDateFormatter dateFromString:[flightsXML attributeNamed:@"lastUpdate"]];
                
                _flightViewController.lastUpdateDate = lastUpdateDate;
                [_flightViewController performSelector:@selector(updateLabels)];
                
            }
        }
	}
    flightsData = nil;
    NSSortDescriptor *sorter;
    
    sorter = [[NSSortDescriptor alloc]initWithKey:@"scheduleTime" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sorter];    
    [flights sortUsingDescriptors:sortDescriptors];
    //
    sections = [NSMutableDictionary dictionary];
    for (Flight *bFlight in flights) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        NSString* dateString = [dateFormatter stringFromDate:bFlight.scheduleTime];
        
        NSMutableArray * theMutableArray = [sections objectForKey:dateString];
        if (theMutableArray == nil) {
            theMutableArray = [NSMutableArray array];
            [sections setObject:theMutableArray forKey:dateString];
        } 
        [theMutableArray addObject:bFlight];
    }
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];

    sortedDates = [sections.allKeys mutableCopy];// sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    //    sortedDates = [sections.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    }); 
    [pull finishedLoading];
    
}
#pragma mark Notification
//-(void)notifyWithFlight:(Flight *)flight{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"no_NO"];
//    dateFormatter.timeStyle = NSDateFormatterShortStyle;
//    dateFormatter.dateStyle = NSDateFormatterNoStyle;
//    NSString *statusText;
//
//    if ([flight.statusCode isEqualToString:@"E"]) {
//        if (flight.statusTime) {
//            if (flight.isArrivalNotDeparture) {
//                statusText = [NSString stringWithFormat:@"Arrival %@", [flight.statusTime distanceOfTimeInWords]];
//            }else
//                statusText = [NSString stringWithFormat:@"Departure %@", [flight.statusTime distanceOfTimeInWords]];
//        }
//    }
//    
//    //	[datePicker setDate:[NSDate date]];
//    if ([flight.statusCode isEqualToString:@"C"]) {
//        
//        if (flight.statusTime) {
//            statusText = [NSString stringWithFormat:@"Cancelled %@", [flight.statusTime distanceOfTimeInWords]];
//        }
//        else
//            statusText = @"Cancelled";
//    }
//    if ([flight.statusCode isEqualToString:@"A"]) {
//        if (flight.statusTime) {
//            statusText = [NSString stringWithFormat:@"Landed %@", [flight.statusTime distanceOfTimeInWords]];
//        }
//        else
//            statusText = @"Landed";
//    }
//    if ([flight.statusCode isEqualToString:@"D"]) {
//        if (flight.statusTime) {
//            statusText = [NSString stringWithFormat:@"Departured %@", [flight.statusTime distanceOfTimeInWords]];
//        }
//        else
//            statusText = @"Departured";
//    }
//    if ([flight.statusCode isEqualToString:@"N"]) {
//        if (flight.statusTime) {
//            statusText = [NSString stringWithFormat:@"New info %@", [flight.statusTime distanceOfTimeInWords]];
//        }
//        else
//            statusText = @"New info";
//    }
//    //    //Flight type
//    //    if ([flight.domInt isEqualToString:@"D"]) {
//    //        _domInt.text = @"Domestic";
//    //    } 
//    //    else if ([flight.domInt isEqualToString:@"S"])
//    //    {
//    //        _domInt.text = @"Schengen";
//    //    }
//    //    else if ([flight.domInt isEqualToString:@"I"])
//    //    {
//    //        _domInt.text = @"International";
//    //    }
//    NSString *actionText;
//    actionText = nil;
//    if ([flight.beltNo length] > 0) {
//        actionText = [NSString stringWithFormat:@"Belt No. %@", flight.beltNo];
//    }
//    if ([flight.checkIn length] > 0) {
//        actionText = [NSString stringWithFormat:@"Check In %@", flight.checkIn];
//    }
//    if ([flight.gate length] > 0) {
//        actionText = [NSString stringWithFormat:@"Gate No. %@", flight.gate];
//    }
//    
//    
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif == nil)
//        return;
//    localNotif.fireDate = [NSDate date];
//    localNotif.timeZone = [NSTimeZone defaultTimeZone];
//    
//    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", nil),
//                            statusText, actionText];
//    //    if (sight.sound) {
//    localNotif.alertAction = NSLocalizedString(@"Show", nil);
//    //    }
//    //    else
//    //        localNotif.alertAction = NSLocalizedString(@"Nothing", nil);
//    
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    //    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    //    localNotif.applicationIconBadgeNumber = 1;
//    
//    //    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:sight.label forKey:ToDoItemKey];
//    //    localNotif.userInfo = infoDict;
//    [UIApplication sharedApplication].applicationIconBadgeNumber++;
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//    NSLog(@"%@, %@", actionText, statusText);
//}
//#pragma mark - Refresh
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view{
    [self downloadFlights];
}
// called when the date shown needs to be updated, optional
- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view{
    return [NSDate date];
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */

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
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
//    barButtonItem.title = NSLocalizedString(@"Airport", nil);
//    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self->masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self->masterPopoverController = nil;
}

@end
