//
//  MGCDimmedCollectionReusableView.h
//  CalendarLib
//
//  Created by Ilya Borshchov on 8/6/19.
//

#import <UIKit/UIKit.h>

@class MGCDateRange;

typedef enum: NSUInteger {
    MCDimmedTypeTop,
    MCDimmedTypeTopBlueBorders,
    MCDimmedTypeMiddle,
    MCDimmedTypeBottom,
    MCDimmedTypeBottomBlueBorders,
    MCDimmedTypeNone = 100
} MCDimmedCollectionViewType;

NS_ASSUME_NONNULL_BEGIN

@interface MGCDimmedCollectionReusableView : UICollectionReusableView

@property (assign, nonatomic) MCDimmedCollectionViewType viewType;
@property (strong, nonatomic) UIColor *scheduleBorderColor;
@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGFloat itemHeight;
@property (assign, nonatomic) CGFloat patternWidth;
@property (assign, nonatomic) CGFloat patternOffset;
// allow to draw lines on background
@property (assign, nonatomic) BOOL shouldDrawShirt;
@property (strong, nonatomic) MGCDateRange *timeRange;

@end

NS_ASSUME_NONNULL_END
