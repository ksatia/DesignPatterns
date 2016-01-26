//
//  PersistencyManager.h
//  BlueLibrary
//
//  Created by Karan Satia on 1/7/16.
//

#import <Foundation/Foundation.h>
#import "Album.h"

@interface PersistencyManager : NSObject

- (NSArray*)getAlbums;
- (void)addAlbum:(Album*)album atIndex:(int)index;
- (void)deleteAlbumAtIndex:(int)index;

- (void)saveImage:(UIImage*)image filename:(NSString*)filename;
- (UIImage*)getImage:(NSString*)filename;
- (void)saveAlbums;

@end
