//
//  PersistencyManager.m
//  BlueLibrary
//
//  Created by Karan Satia on 1/7/16.
//

#import "PersistencyManager.h"


//class extension to include a private property variable. Must declare only the subclass name after the @interface directive, followed by ()

@interface PersistencyManager ()
@property (strong, nonatomic) NSMutableArray *albums;
@end

@implementation PersistencyManager


- (id)init
{
    self = [super init];
    
    if (self) {
        //check the contents of our keyedarchives and see if we have anything there.
        NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"]];
        self.albums = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (self.albums == nil) {
            
        self.albums = [NSMutableArray new];
            //only use one instance of album. we can keep changing that as long as we add to an array before the change happens - the array maintains reference to the object state at the time it is added to the array, and can simply reuse the memory allocated for the ONE album object.
        Album * album = [[Album alloc] initWithTitle:@"Best of Bowie" artist:@"David Bowie" coverUrl:@"https://upload.wikimedia.org/wikipedia/en/2/29/Best_of_bowie.jpg" year:@"1992"];
        [self.albums addObject:album];
        
        album = [[Album alloc] initWithTitle:@"It's My Life" artist:@"No Doubt" coverUrl:@"http://bestcoversongs.net/images/no-doubt-its-my-life-cover.jpg" year:@"2003"];
        [self.albums addObject:album];
        
        album = [[Album alloc] initWithTitle:@"Nothing Like The Sun" artist:@"Sting" coverUrl:@"http://cdn.discogs.com/bwbP10THjvl8hbtb9PRstGSVKUM=/fit-in/300x300/filters:strip_icc():format(jpeg):mode_rgb()/discogs-images/R-461532-1427910040-7080.jpeg.jpg" year:@"1999"];
        [self.albums addObject:album];
        
        album = [[Album alloc]initWithTitle:@"American Pie" artist:@"Madonna" coverUrl:@"http://ecx.images-amazon.com/images/I/41Q9DG8AYDL.jpg" year:@"2000"];
        [self.albums addObject:album];
        [self saveAlbums];
        }
    }
    return self;
}


- (NSArray*)getAlbums {
    return self.albums;
}

- (void)addAlbum:(Album*)album atIndex:(int)index{
    if (self.albums.count>=index) {
        [self.albums insertObject:album atIndex:index];
    }
    
    //if index is way higher than the current numer of objects, just ignore the requested index and throw it in at the end of the array.
    else {
        [self.albums addObject:album];
    }
}


- (void)deleteAlbumAtIndex:(int)index{
    [self.albums removeObjectAtIndex:index];
}

- (void)saveImage:(UIImage*)image filename:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filename atomically:YES];
}

- (UIImage*)getImage:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    return [UIImage imageWithData:data];
}

- (void)saveAlbums
{
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.albums];
    [data writeToFile:filename atomically:YES];
}



@end
