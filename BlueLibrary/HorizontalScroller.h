//  HorizontalScroller.h
//  Created by Karan Satia on 1/11/16.

#import <UIKit/UIKit.h>

//forward declare protocol, since it is declared BELOW the interfact @end marker. It wouldn't be visible to us otherwise.
@protocol HorizontalScrollerDelegate;

@interface HorizontalScroller : UIView <UIScrollViewDelegate>

//Must be weak to avoid retain cycle. If we have a UIViewController & create an instance of HorizontalScroller and set the delegate to be self, we have a retain cycle. The UIViewController has a strong reference to HorizontalScroller (makes sense, it created it AND we want to make sure the scroller exists for the lifetime of the UIViewController) and the HorizontalScroller will have a strong reference to the delegate object (in this case, back tot eh UIViewController). Two strong pointers to each other = retain cycle; thus, make the delegate weak.

// id<protocolname> ensures that the delegate object has an object type that conforms to the HorizontalScrollerDelegate protocol. This gives us some type safety here.

@property (weak) id<HorizontalScrollerDelegate> delegate;

- (void)reload;

@end


@protocol HorizontalScrollerDelegate <NSObject>

@required
// ask delegate how many views to display
- (NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller*)scroller;

// ask the delegate to return the view that should appear at <index>2
- (UIView*)horizontalScroller:(HorizontalScroller*)scroller viewAtIndex:(int)index;

// inform the delegate what the view at <index> has been clicked
- (void)horizontalScroller:(HorizontalScroller*)scroller clickedViewAtIndex:(int)index;

@optional
// ask the delegate for the index of the initial view to display. this method is optional
// and defaults to 0 if it's not implemented by the delegate
- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller*)scroller;


@end
