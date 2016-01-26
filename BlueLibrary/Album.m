//
//  Album.m
//  BlueLibrary
//
//  Created by Karan Satia on 1/7/16.
//

#import "Album.h"


@implementation Album

-(id)initWithTitle:(NSString *)title artist:(NSString *)artist coverUrl:(NSString *)coverUrl year:(NSString *)year {
    self = [super init];
    if (self) {
        //the property variables are readonly so we must change the values of the ivars backing the properties. Question - do we even need properties at all, since our category "tablerepresentation" actually accesses these values? The answer is YES because categories cannot read ivars! We must have properties in order for them to be accessible by another class, even if it is a category.
        
        _title = title;
        _artist = artist;
       _coverUrl = coverUrl;
       _year = year;
       _genre = @"Pop";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.year forKey:@"year"];
    [aCoder encodeObject:self.title forKey:@"album"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.coverUrl forKey:@"cover_url"];
    [aCoder encodeObject:self.genre forKey:@"genre"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _year = [aDecoder decodeObjectForKey:@"year"];
        _title = [aDecoder decodeObjectForKey:@"album"];
        _artist = [aDecoder decodeObjectForKey:@"artist"];
        _coverUrl = [aDecoder decodeObjectForKey:@"cover_url"];
        _genre = [aDecoder decodeObjectForKey:@"genre"];
    }
    return self;
}


@end
