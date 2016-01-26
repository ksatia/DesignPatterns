//
//  LibraryAPI.h
//  BlueLibrary
//
//  Created by Karan Satia on 1/7/16.
//

#import <Foundation/Foundation.h>
#import "Album.h"

@interface LibraryAPI : NSObject


+(LibraryAPI *)sharedInstance;
- (NSArray*)getAlbums;
- (void)addAlbum:(Album*)album atIndex:(int)index;
- (void)deleteAlbumAtIndex:(int)index;
- (void)saveAlbums;


@end
