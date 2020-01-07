//
//  MGCDimmedCollectionReusableView.h
//  CalendarLib
//
//  Created by Ilya Borshchov on 8/6/19.
//

#import <UIKit/UIKit.h>

typedef enum: NSUInteger {
    MCDimmedTypeTop,
    MCDimmedTypeMiddle,
    MCDimmedTypeBottom,
    MCDimmedTypeNone = 100
} MCDimmedCollectionViewType;

NS_ASSUME_NONNULL_BEGIN

@interface MGCDimmedCollectionReusableView : UICollectionReusableView

@property (assign, nonatomic) MCDimmedCollectionViewType viewType;
@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGFloat itemHeight;
@property (assign, nonatomic) CGFloat patternWidth;
@property (assign, nonatomic) CGFloat patternOffset;
// allow to draw lines on background
@property (assign, nonatomic) BOOL shouldDrawShirt;

@end

NS_ASSUME_NONNULL_END
