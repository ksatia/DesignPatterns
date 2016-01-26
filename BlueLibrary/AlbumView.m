//
//  AlbumView.m
//  BlueLibrary
//
//  Created by Karan Satia on 1/7/16.
//

#import "AlbumView.h"

//regular ivars
@implementation AlbumView {
    
    UIImageView *coverImage;
    UIActivityIndicatorView *indicator;
    
}


-(id)initWithFrame:(CGRect)frame albumCover:(NSString *)albumCover {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
        [self addSubview:coverImage];
        indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        indicator.center = coverImage.center;
        [indicator startAnimating];
        
        //KVO SETUP
        [coverImage addObserver:self forKeyPath:@"image" options:0 context:nil];
        
        [self addSubview:indicator];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLDownloadImageNotification"
                                                            object:self
                                                          userInfo:@{@"imageView":coverImage, @"coverUrl":albumCover}];
    }
    
    return self;
    
}

- (void)dealloc
{
    [coverImage removeObserver:self forKeyPath:@"image"];
}

//KVO implementation. We've add the observation, now we implement the action.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"])
    {
        [indicator stopAnimating];
    }
}


@end
