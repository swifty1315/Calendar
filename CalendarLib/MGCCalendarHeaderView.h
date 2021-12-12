//
//  CalendarHeaderView.h
//  Calendar
//
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MGCDayPlannerView;

@interface MGCCalendarHeaderView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

/*!
 @abstract    Text color of date
 @discussion White with 0.8 alpha by default
 */
@property (nonatomic, strong) UIColor *dayTextColor;

/*!
 @abstract    The current selected date on the calendar
 @discussion Read only, you can set the visible date via selectDate
 */
@property (nonatomic, readonly) NSDate *selectedDate;

/*!
 @abstract    The accent color
 @discussion White with 0.8 alpha by default
 */
@property (nonatomic, strong) UIColor *accentColor;

/*!
 @abstract    Text color of selected date
 @discussion White with 0.8 alpha by default
 */
@property (nonatomic, strong) UIColor *selectedDayTextColor;

 /*!
 @abstract    Background color of selected date
 */
@property (nonatomic, strong) UIColor *selectedDayBackgroundColor;

/*!
 @abstract    Text color of weekend date
 */

@property (nonatomic, strong) UIColor *weekendColor;

/*!
 @abstract    Date text color
 */

@property (nonatomic, strong) UIColor *dateTextColor;

/*!
 @abstract    Week day font
 */

@property (nonatomic, strong) UIFont *dayNameFont;

/*!
 @abstract    Day number font
 */

@property (nonatomic, strong) UIFont *dayNumberFont;

/*!
 @abstract    Day number font selected
 */

@property (nonatomic, strong) UIFont *dayNumberFontSelected;

/*!
 
 @abstract    The header background color
 @discussion Light gray by default
 */
@property (nonatomic, strong) UIColor *headerBackgroundColor;
/*!
 @abstract    Initialization
 @discussion The day planner view instance needs to be passed along
 */
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout andDayPlannerView:(MGCDayPlannerView *)dayPlannerView;

/*!
 @abstract  Sets and moves the header view to the given date
 @parameter date the date to be set
 */
- (void)selectDate:(NSDate *)date;


/*!
 
 @abstract  Reload data and apply new styles
 
 */

- (void)refreshAppearance;

@end
