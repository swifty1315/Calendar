//
//  MGCDimmedCollectionReusableView.h
//  CalendarLib
//
//  Created by Ilya Borshchov on 8/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MGCDimmedCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGFloat itemHeight;
// allow to draw lines on background
@property (assign, nonatomic) BOOL shouldDrawShirt;

@end

NS_ASSUME_NONNULL_END
