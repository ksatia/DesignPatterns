//
//  LibraryAPI.m
//  BlueLibrary
//
//  Created by Karan Satia on 1/7/16.
//

#import "LibraryAPI.h"
#import "HTTPClient.h"
#import "PersistencyManager.h"

//private ivars
@interface LibraryAPI () {
    BOOL isOnline;
    HTTPClient *httpClient;
    PersistencyManager *persistencyManager;
}
@end


@implementation LibraryAPI
//this is our master API in using the facade design pattern. We can manage our HTTP client (to download images) and our persistency manager (to manage local saved versions of the albums) right from here. The other classes may use the services provided by the HTTP client adn the PersistencyManager, but they don't need to know about their actual existence nor how they work. They just need to get the service, which they can access through our LibraryAPI master API using the facade design pattern.

+(LibraryAPI *)sharedInstance {
    //static variable so globally available and holds state between functions - dispatch_once ensures single initialization
    static dispatch_once_t oncePredicate;
    //globally available static variable, return ivar and set to nil for first initialization
    static LibraryAPI * sharedInstance = nil;
    //call GCD dispatch_once block (thread-safety is automatic)
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[LibraryAPI alloc]init];
    });
    return sharedInstance;
}

//This is called from our sharedInstance first initialization.
-(instancetype)init {
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc]init];
        httpClient = [[HTTPClient alloc]init];
        isOnline = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"BLDownloadImageNotification" object:nil];
    }
    return self;
}

- (void)downloadImage:(NSNotification*)notification
{
    // 1
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *coverUrl = notification.userInfo[@"coverUrl"];
    
    // 2
    imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    
    if (imageView.image == nil)
    {
        // run image download on a background queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [httpClient downloadImage:coverUrl];
            
            // return to main queue in order to update the UI
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [persistencyManager saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(NSArray *)getAlbums {
    return [persistencyManager getAlbums];
}

-(void)deleteAlbumAtIndex:(int)index {
    [persistencyManager deleteAlbumAtIndex:index];
    //this is where the facade pattern shines. If some client deletes an album, they'll see an album get deleted. They don't need to know that we're deleting both locally AND from the server. The complexity is hidden from them using a managing API (LibraryAPI in this case).
    if (isOnline) {
        [httpClient postRequest:@"/api/deleteAlbum" body:[@(index) description]];
    }
}

-(void)addAlbum:(Album *)album atIndex:(int)index {
    [persistencyManager addAlbum:album atIndex:index];
    if (isOnline) {
        [httpClient postRequest:@"/api/addAlbum" body:[album description]];
    }
}

- (void)saveAlbums {
    [persistencyManager saveAlbums];
}


@end
