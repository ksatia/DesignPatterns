//
//  Album.h
//  BlueLibrary
//
//  Created by Karan Satia on 1/7/16.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject <NSCoding>


@property (strong, nonatomic, readonly) NSString *title, *artist, *genre, *coverUrl, *year;
- (id)initWithTitle:(NSString*)title artist:(NSString*)artist coverUrl:(NSString*)coverUrl year:(NSString*)year;

@end
