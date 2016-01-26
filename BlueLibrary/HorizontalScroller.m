//
//  HorizontalScroller.m
//  BlueLibrary
//
//  Created by Karan Satia on 1/11/16.
// THIS IS A VIEW CLASS THAT WE ARE ALSO DECLARING A PROTOCOL IN (the view has a delegate that must adhere to the view's protocol). We could declare the protocol in a separate class, but we're doing it here because there isn't too much code and it's easier to see it working together in a single file.

#import "HorizontalScroller.h"

#define VIEW_PADDING 10
#define VIEW_DIMENSIONS 100
#define VIEWS_OFFSET 100


@implementation HorizontalScroller
{
    //this is our scroll view container to hold our album cover images. Here it is considered a private ivar. If we included it in an @interface block RIGHT ABOVE THIS, it would be a class extension (and we would use properties instead of non-attributable ivars).
    UIScrollView *scroller;
}


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //Two delegates being used when we create instance of HorizontalScroller in a controller class. We have the delegate for HorizontalScroller, and HorizontalScroller itself is a delegate for the contained subview. The HorizontalScroller is really just a container view.
        scroller.delegate = self;
        [self addSubview:scroller];
        
        //add a gesture recognizer so we can handle when somebody taps the scroller. Call a scrollerTapped method.
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];
    }
    return self;
}


-(void)scrollerTapped:(UITapGestureRecognizer *)gesture {
        CGPoint location = [gesture locationInView:gesture.view];
        // we can't use an enumerator here, because we don't want to enumerate over ALL of the UIScrollView subviews.
        // we want to enumerate only the subviews that we added
        for (int index=0; index<[self.delegate numberOfViewsForHorizontalScroller:self]; index++)
        {
            UIView *view = scroller.subviews[index];
            if (CGRectContainsPoint(view.frame, location))
            {
                [self.delegate horizontalScroller:self clickedViewAtIndex:index];
                
                //center the tapped album cover view in the horizontal scroller
                [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
                break;
            }
      }
}


- (void)reload
{
    // 1 - nothing to load if there's no delegate
    if (self.delegate == nil) return;
    
    // 2 - remove all subviews
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // 3 - xValue is the starting point of the views inside the scroller
    CGFloat xValue = VIEWS_OFFSET;
    for (int i=0; i<[self.delegate numberOfViewsForHorizontalScroller:self]; i++)
    {
        // 4 - add a view at the right position
        xValue += VIEW_PADDING;
        UIView *view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(xValue, VIEW_PADDING, VIEW_DIMENSIONS, VIEW_DIMENSIONS);
        [scroller addSubview:view];
        xValue += VIEW_DIMENSIONS+VIEW_PADDING;
    }
    
    // 5
    [scroller setContentSize:CGSizeMake(xValue+VIEWS_OFFSET, self.frame.size.height)];
    
    // 6 - if an initial view is defined, center the scroller on it
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)])
    {
        long initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        [scroller setContentOffset:CGPointMake(initialView*(VIEW_DIMENSIONS+(2*VIEW_PADDING)), 0) animated:YES];
    }
}

//this is a UIKit callback method that checks to see if we changed the view heirarchy aka moved to a different view and came back to this one
- (void)didMoveToSuperview
{
    [self reload];
}


- (void)centerCurrentView
{
    int xFinal = scroller.contentOffset.x + (VIEWS_OFFSET/2) + VIEW_PADDING;
    int viewIndex = xFinal / (VIEW_DIMENSIONS+(2*VIEW_PADDING));
    xFinal = viewIndex * (VIEW_DIMENSIONS+(2*VIEW_PADDING));
    [scroller setContentOffset:CGPointMake(xFinal,0) animated:YES];
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self centerCurrentView];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
}



@end