//
//  ViewController.m
//  Spiny Dogfish
//
//  Created by Max Korenkov on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Eng2RuHTMLParser.h"
#import "Eng2RuNotFoundException.h"
#import "Eng2RuPostProcessor.h"
#import "iRate.h"

@implementation ViewController
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize textView;
@synthesize tableView;
@synthesize progressView;
@synthesize allItems;
@synthesize searchResults;
@synthesize searching;

+ (void)configureIRate {
    //configure iRate
    [iRate sharedInstance].appStoreID = 492543900; // App Id
    [iRate sharedInstance].daysUntilPrompt = 7;
    [iRate sharedInstance].usesUntilPrompt = 13;
    [iRate sharedInstance].remindPeriod = 7;

    [iRate sharedInstance].messageTitle = NSLocalizedString(@"Rate me", @"Rate me message title");
    [iRate sharedInstance].message = NSLocalizedString(@"Would you like to rate Spiny Dogfish application on App Store?",
                        @"Message body");
    [iRate sharedInstance].cancelButtonLabel = NSLocalizedString(@"No, never", @"Cancel label value");
    [iRate sharedInstance].rateButtonLabel = NSLocalizedString(@"Sure, why not", @"Rate label value");
    [iRate sharedInstance].remindButtonLabel = NSLocalizedString(@"Later", @"Remind label value");

    [iRate sharedInstance].debug = YES;
}

+ (void)initialize {
    [self configureIRate];
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
	
    self.searching = FALSE;
    self.tableView.scrollEnabled = YES;
    self.textView.scrollEnabled = true;

    //todo: load from SQL databases
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:
                      @"Armor",@"Quest",@"Sudden",nil];
    
    self.allItems = items;

    [self.tableView reloadData];
    NSLog(@"viewDidLoad executed");
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setSearchDisplayController:nil];
    [self setTextView:nil];
    [self setTableView:nil];
    [self setProgressView:nil];
    [self setTableView:nil];
    
    [self setView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    NSLog(@"viewDidUnload executed");
}

- (void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated]; }
- (void)viewDidAppear:(BOOL)animated { [super viewDidAppear:animated]; }
- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated]; }
- (void)viewDidDisappear:(BOOL)animated { [super viewDidDisappear:animated]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView { return 1; }

- (NSInteger)tableView:(UITableView *)theTableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if ([theTableView
         isEqual:self.searchDisplayController.searchResultsTableView]){
        rows = [self.searchResults count];
    }
    else{
        rows = [self.allItems count];
    }
    
    return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [theTableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    /* Configure the cell. */
    if ([theTableView isEqual:self.searchDisplayController.searchResultsTableView]){
        cell.textLabel.text = 
        [self.searchResults objectAtIndex:indexPath.row];
    }
    else{
        cell.textLabel.text =
        [self.allItems objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate 
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];

    self.searchResults = [self.allItems filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    //[self.searchResults removeAllObjects];// remove all data that belongs to previous search
    if([searchText isEqualToString:@""] || searchText==nil) {
        [self.tableView reloadData];
        return;
    }
    [self filterContentForSearchText:searchText];
    [self.tableView reloadData];
    NSLog(@"textDidChange executed");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
    [self.tableView reloadData];
    [theSearchBar resignFirstResponder];
    theSearchBar.text = @"";
}

#pragma mark UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar { theSearchBar.showsCancelButton = YES; }

- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar { theSearchBar.showsCancelButton = NO; }



enum State {
    None,
    Searching,
    FinishedSearching,
    ShowTranslation
} state;

- (void)switchState:(enum State) theState {
    switch (theState) {
        case None:
            break;
        case Searching:
            self.searchDisplayController.searchResultsTableView.hidden = true;
            self.progressView.hidden = false;
            self.tableView.hidden = true;
            self.textView.hidden = true;
            self.progressView.progress = 0.05;
            [self.progressView becomeFirstResponder];
            break;
        case FinishedSearching:
            self.searchDisplayController.searchResultsTableView.hidden = false;
            self.progressView.hidden = true;
            self.tableView.hidden = false;
            self.textView.hidden = true;
            [self.tableView becomeFirstResponder];
            break;
        case ShowTranslation:
            self.searchDisplayController.searchResultsTableView.hidden = true;
            self.progressView.hidden = true;
            self.tableView.hidden = true;
            self.textView.hidden = false;
            [self.textView becomeFirstResponder];
            break;
        default:
            //todo: throw error
            break;
    }
    state = theState;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)theSearchBar{
    if(state == Searching) {
        return false;
    } else {
        [self switchState: FinishedSearching];
        return true;
    }
}

-(void)makeProgress{
    if (1 - self.progressView.progress < 0.17 ||
            self.progressView.progress > 1) {
        self.progressView.progress = 1;
    } else {
        self.progressView.progress += 0.17;
    }
}

// called when Search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    //sending request to lingvo
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //trimming and removing whitespaces
    NSString *search = [self.searchBar.text lowercaseString];
    NSCharacterSet* charsToTrim = [NSCharacterSet characterSetWithCharactersInString:@" \n\r\t"];
    NSString* trimmedSearch = [search stringByTrimmingCharactersInSet:charsToTrim];

    NSString *url = [[NSString alloc] initWithFormat:@"http://eng2.ru/%@", trimmedSearch];
    NSLog(@"URL: %@", url);

    //todo:check symbols @"!*'();:@&=+$,/?%#[]",

    [request setURL:[NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"SpinyDogfish/1.0" forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"text/plain, text/html" forHTTPHeaderField:@"Accept"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];

    //end of request
    [self switchState:Searching];
}

-(void)sendDebugStatistics:(NSString *) word:
        (NSString *) dictionary:
        (NSString *) transcription:
        (NSString *) translation {
    NSString *url = @"http://spinyanalytics.appspot.com/submit";
    NSMutableString *body = [[NSMutableString alloc] initWithString:@"{\n"];
    [body appendFormat:@"\"word\":\"%@\",\n", [word stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [body appendFormat:@"\"dictionary\":\"%@\",\n", [dictionary stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [body appendFormat:@"\"transcription\":\"%@\",\n", [transcription stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [body appendFormat:@"\"translation\":\"%@\"\n", [translation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [body appendString:@"}"];

    NSLog( @"debug url§: %@", url);
    NSLog( @"debug body: %@", body);

    NSObject *dummy = [[NSObject alloc] init];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"SpinyDogfish/1.0" forHTTPHeaderField:@"User-Agent"];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%d",
            [body length]]
            forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[body
            dataUsingEncoding:NSUTF8StringEncoding]];
    [[NSURLConnection alloc] initWithRequest:request delegate:dummy startImmediately:TRUE];

}


NSMutableData *_data;

-(void)dataCardNotFound {
    //todo:Handle the error properly
    NSLog( @"word not found" );
    [self switchState:FinishedSearching];
}

-(void)dataCardParsed:(NSMutableString *)result {
    Eng2RuPostProcessor *processor = [[Eng2RuPostProcessor alloc] init];
    [processor process:result];
    NSLog(@"Translation: %@", [processor getTranslation]);
    self.textView.text = [processor fixIndentation:[processor getTranslation]];
    [self switchState:ShowTranslation];
    [self sendDebugStatistics:
            [processor getWord] :
            [processor getDictionary] :
            [processor getTranscriptionUrl] :
            [processor getTranslation]];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    _data = [[NSMutableData alloc] init]; // _data being an ivar
    [self makeProgress];
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
    [self makeProgress];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    //todo:Handle the error properly
    NSLog( @"Error: %@", error.description);
    [self switchState:FinishedSearching];
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
    NSLog( @"HTML: %@", [[NSString alloc] initWithData:_data
                encoding:NSUTF8StringEncoding]);
    Eng2RuHTMLParser *parser = [[Eng2RuHTMLParser alloc] init];
    @try {
        NSMutableString *result = [parser parseHTMLData:_data];
        [self dataCardParsed:result];
    } @catch (Eng2RuNotFoundException *e) {
        [self dataCardNotFound];
    }
}

@end
