//
//  ViewController.m
//  BlueLibrary
//
//

#import "ViewController.h"
#import "Album+TableRepresentation.h"
#import "LibraryAPI.h"
#import "AlbumView.h"
#import "HorizontalScroller.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, HorizontalScrollerDelegate> {
    
    HorizontalScroller *scroller;

}

@property (strong, nonatomic) UITableView *dataTable;
@property (strong, nonatomic) NSArray *allAlbums;
@property (strong, nonatomic) NSDictionary *currentAlbumData;
@property int currentAlbumIndex;
@property UIToolbar *toolbar;
@property NSMutableArray *undoStack;

@end

@implementation ViewController


- (void)viewDidLoad {
    self.toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoAction)];
    undoItem.enabled = NO;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAlbum)];
    [self.toolbar setItems:@[undoItem,space,delete]];
    [self.view addSubview:self.toolbar];
    self.undoStack = [[NSMutableArray alloc] init];

    //make sure to intiailize superclass method and set background color
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:.76f green:.81f blue:.87f alpha:1];
    self.currentAlbumIndex = 0;
    
    //this initializes our LibraryAPI, which initializes our persistencyManager (and thus creates our album array). getAlbums in turn calls the persistencyManager getAlbums method, which returns the album array and stores it here in our extension variable.
    self.allAlbums = [[LibraryAPI sharedInstance] getAlbums];
    
    //set up tableview and its delegate
    self.dataTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height-120) style:UITableViewStyleGrouped];
    self.dataTable.delegate = self;
    self.dataTable.dataSource = self;
    self.dataTable.backgroundView = nil;
    [self.view addSubview:self.dataTable];
    
    [self loadPreviousState];
    //add scroller to the view
    scroller = [[HorizontalScroller alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    scroller.backgroundColor = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
    scroller.delegate = self;
    [self.view addSubview:scroller];
    
    [self reloadScroller];
    
    [self showDataForAlbumAtIndex:self.currentAlbumIndex];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentState) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillLayoutSubviews
{
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    self.dataTable.frame = CGRectMake(0, 130, self.view.frame.size.width, self.view.frame.size.height - 200);
}

- (void)addAlbum:(Album*)album atIndex:(int)index
{
    [[LibraryAPI sharedInstance] addAlbum:album atIndex:index];
   self.currentAlbumIndex = index;
    [self reloadScroller];
}

- (void)deleteAlbum
{
    Album *deletedAlbum = self.allAlbums[self.currentAlbumIndex];

    //if we delete an album, we need to hang on to that object temporarily in case we choose to undo the action. We create a method signature and set it to our add album method.
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(addAlbum:atIndex:)];
    NSInvocation *undoAction = [NSInvocation invocationWithMethodSignature:sig];
    //target argument
    [undoAction setTarget:self];
    //selector argument
    [undoAction setSelector:@selector(addAlbum:atIndex:)];
    
    //these indices are used to refer to the argument position of the method being passed (starting with 2, we have the album argument and then the index argument). We use the memory address as arguments.
    //memory address of deleted album contains Album object
    [undoAction setArgument:&deletedAlbum atIndex:2];
    //memory address of deleted album contains integer denoting index in album array model.
    [undoAction setArgument:&_currentAlbumIndex atIndex:3];
    [undoAction retainArguments];
    
    [self.undoStack addObject:undoAction];
    
    [[LibraryAPI sharedInstance] deleteAlbumAtIndex:self.currentAlbumIndex];
    [self reloadScroller];
    
    //enable undo button since there is now an object in the undo stack
    [self.toolbar.items[0] setEnabled:YES];
}


- (void)undoAction
{
    if (self.undoStack.count > 0)
    {
        NSInvocation *undoAction = [self.undoStack lastObject];
        [self.undoStack removeLastObject];
        [undoAction invoke];
    }
    
    //if there is nothing to do, disable the undo button
    if (self.undoStack.count == 0)
    {
        [self.toolbar.items[0] setEnabled:NO];
    }
}





- (void)showDataForAlbumAtIndex:(int)albumIndex
{
    // defensive code: make sure the requested index is lower than the amount of albums
    if (albumIndex < self.allAlbums.count)
    {
        // fetch the album
        Album *album = self.allAlbums[albumIndex];
        // save the albums data to present it later in the tableview
        self.currentAlbumData = [album tr_tableRepresentation];
    }
    else
    {
        self.currentAlbumData = nil;
    }
    
    // we have the data we need, let's refresh our tableview on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataTable reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentAlbumData[@"titles"] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.currentAlbumData[@"titles"][indexPath.row];
    cell.detailTextLabel.text = self.currentAlbumData[@"values"][indexPath.row];
    
    return cell;
}

#pragma HorizontalScrollerDelegate Methods
-(void)horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(int)index {
    self.currentAlbumIndex = index;
    [self showDataForAlbumAtIndex:index];
}

- (NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller*)scroller
{
    return self.allAlbums.count;
}


- (UIView*)horizontalScroller:(HorizontalScroller*)scroller viewAtIndex:(int)index
{
    Album *album = self.allAlbums[index];
    return [[AlbumView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) albumCover:album.coverUrl];
}


- (void)reloadScroller
{
    self.allAlbums = [[LibraryAPI sharedInstance] getAlbums];
    if (self.currentAlbumIndex < 0) self.currentAlbumIndex = 0;
    else if (self.currentAlbumIndex >= self.allAlbums.count) {
     self.currentAlbumIndex = self.allAlbums.count-1;   
    }
    [scroller reload];
    [self showDataForAlbumAtIndex:self.currentAlbumIndex];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller *)scroller
{
    return self.currentAlbumIndex;
}

- (void)saveCurrentState
{
    // When the user leaves the app and then comes back again, he wants it to be in the exact same state
    // he left it. In order to do this we need to save the currently displayed album.
    // Since it's only one piece of information we can use NSUserDefaults.
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentAlbumIndex forKey:@"currentAlbumIndex"];
    [[LibraryAPI sharedInstance] saveAlbums];
}

- (void)loadPreviousState
{
    self.currentAlbumIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentAlbumIndex"];
    [self showDataForAlbumAtIndex:self.currentAlbumIndex];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
