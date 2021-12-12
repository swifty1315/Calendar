//
//  CalendarHeaderView.m
//  Calendar
//
//  Copyright © 2016 Julien Martin. All rights reserved.
//

#import "MGCCalendarHeaderView.h"
#import "MGCCalendarHeaderCell.h"
#import "MGCDayPlannerView.h"

typedef NS_ENUM(NSInteger, HeaderSection){
    PreviousWeekSection = 0,
    CurrentWeekSection,
    NextWeekSection
};

@interface  MGCCalendarHeaderView ()

@property (nonatomic, strong) MGCDayPlannerView *dayPlannerView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) NSInteger weekIndex; //keeps the count of scrolls left or right, where 0 is no scrolls -1 is one scroll left +1 is one scroll right
@property (nonatomic, assign) CGPoint previousContentOffset;
@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, assign) NSInteger selectedDateIndex;
@property (nonatomic, strong) NSDate *todayDate;
@property (nonatomic, readwrite) NSDate *selectedDate;

@property (nonatomic, strong) NSArray *previousWeekDates;
@property (nonatomic, strong) NSArray *currentWeekDates;
@property (nonatomic, strong) NSArray *nextWeekDates;

@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic, strong) NSDateFormatter *detailsDateFormater;

@end

@implementation MGCCalendarHeaderView

static NSString *kCellIdentifier = @"CalendarHeaderCellId";
static NSInteger kNumberOfDaysToDisplay = 7; //one week
static CGFloat kDetailsLabelHeight = 0;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout andDayPlannerView:(MGCDayPlannerView *)dayPlannerView
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        
        self.dayPlannerView = dayPlannerView;
        self.headerBackgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        
        //setup the flow layout
        self.flowLayout = (UICollectionViewFlowLayout*)layout;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.flowLayout.sectionInset = UIEdgeInsetsZero;
        self.flowLayout.minimumLineSpacing = 0;
        self.flowLayout.minimumInteritemSpacing = 0;
        
        self.weekIndex = 0; //0 represents the current week <1 past weeks one and >1 future weeks
        
        //setup a calendar to do the dates calculations
        self.calendar = [NSCalendar currentCalendar];
        [self.calendar setLocale:[NSLocale currentLocale]]; //use the current locale to fit the user region
        self.selectedDate = [NSDate date];
         [self.calendar setTimeZone:[NSTimeZone localTimeZone]];
        self.selectedDateIndex = [self.calendar component:NSCalendarUnitWeekday fromDate:self.selectedDate];
        // convert week day number to array index
        self.selectedDateIndex = [self getArrayIndexByWeekDayNumber:self.selectedDateIndex];
        //setup the collection view
        self.pagingEnabled = YES;
        self.delegate = self;
        self.dataSource = self;
        self.allowsMultipleSelection = NO;
        self.bounces = NO;
        if (@available(iOS 9.0, *)) {
            self.remembersLastFocusedIndexPath = YES;
        }
        
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = self.headerBackgroundColor;
        
        //Bottom label to display full date
        self.detailsLabel = [[UILabel alloc] initWithFrame:CGRectZero]; //will be resized to fit
        self.detailsLabel.backgroundColor = self.headerBackgroundColor;
        self.detailsLabel.textColor = [UIColor darkGrayColor];
        self.detailsLabel.textAlignment = NSTextAlignmentCenter;
        self.detailsDateFormater = [[NSDateFormatter alloc] init];
        [self.detailsDateFormater setDateStyle:NSDateFormatterFullStyle];
        [self.detailsDateFormater setTimeStyle:NSDateFormatterNoStyle];
        [self.detailsDateFormater setLocale:[NSLocale currentLocale]];
        self.detailsLabel.text = [self.detailsDateFormater stringFromDate:self.selectedDate];
        [self addSubview:self.detailsLabel];
        
        //setup weeks dates
        [self setupWeekDates];
        
        [self registerNib:[UINib nibWithNibName:@"MGCCalendarHeaderCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentifier];
        
        
    }
    return self;
}

- (NSInteger)getArrayIndexByWeekDayNumber:(NSInteger)weekDayNumber{
    
    // monday week day is equal to 2 etc...
    if (weekDayNumber >= 2) {
        // because monday week day is 2 and we dealling with an array from monday to sunday
        weekDayNumber = weekDayNumber - 2;
        return weekDayNumber;
    }
    // sunday week day is equal 1 and should be in the end of array
    return 6;
}

#pragma mark - UIView lifecycle

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat maxItemWidth = self.frame.size.width / kNumberOfDaysToDisplay;
    CGFloat itemHeight = (self.frame.size.width / kNumberOfDaysToDisplay) - 1;
    self.flowLayout.itemSize = CGSizeMake(maxItemWidth, itemHeight);
    
    //always select the same day of the week when switching weeks (as the native apple calendar does)

    [self selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedDateIndex inSection:CurrentWeekSection] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    //recalculate the label size to addapt to rotations
    
    self.detailsLabel.frame = CGRectMake(self.previousContentOffset.x, self.frame.size.height - kDetailsLabelHeight , self.frame.size.width, kDetailsLabelHeight);
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    //do this only the first time to position the scroll in the middle week
    [self layoutIfNeeded];
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:CurrentWeekSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    self.previousContentOffset = self.contentOffset;
}

#pragma mark - Private methods

- (NSArray*)weekDaysFromDate:(NSDate*)date
{
    NSDateComponents* components = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    NSMutableArray<NSDate*>* weekDaysDates = [NSMutableArray array];
    [components setYear:components.year];
    //iterate to fill the dates of the week days
    
    NSDate *startOfWeek;
    NSTimeInterval length;
    [self.calendar rangeOfUnit: NSCalendarUnitWeekOfYear
                                    startDate:&startOfWeek
                                     interval:&length
                                      forDate:date];
    
    [weekDaysDates addObject:startOfWeek];
    
    for (int i = 1; i < 7; i++) { //1 is the comopnent for the first day of week 7 the last
        [weekDaysDates addObject:[startOfWeek dateByAddingTimeInterval:86400*i]];
    }
    
    [weekDaysDates sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate* dt1 = obj1;
        NSDate* dt2 = obj2;
        return [dt1 compare:dt2];
    }];
    
    return weekDaysDates;
}

- (void)setupWeekDates{
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.weekOfYear = self.weekIndex;
    NSDate *currentWeekDate = [self.calendar dateByAddingComponents:components toDate:self.selectedDate options:0];
    self.currentWeekDates = [self weekDaysFromDate:currentWeekDate];
    
    components.weekOfYear = self.weekIndex + 1;
    NSDate *nextWeekDate = [self.calendar dateByAddingComponents:components toDate:self.selectedDate options:0];
    self.nextWeekDates = [self weekDaysFromDate:nextWeekDate];
    
    components.weekOfYear = self.weekIndex - 1;
    NSDate *previousWeekDate = [self.calendar dateByAddingComponents:components toDate:self.selectedDate options:0];
    self.previousWeekDates = [self weekDaysFromDate:previousWeekDate];
}


#pragma mark - Public methods

- (void)refreshAppearance{
    self.backgroundColor = self.headerBackgroundColor;
    [self reloadData];
}

- (void)selectDate:(NSDate *)date{
    
    if(![self.calendar isDate:date inSameDayAsDate:self.selectedDate]){
        
        self.selectedDate = [self.calendar startOfDayForDate:date];
        self.selectedDateIndex = [self.calendar component:NSCalendarUnitWeekday fromDate:self.selectedDate];
        self.selectedDateIndex = [self getArrayIndexByWeekDayNumber:self.selectedDateIndex];
        
        //setup the new weeks dates
        [self setupWeekDates];
        [self reloadData];
        
        //keep the day view synchronized
        [self.dayPlannerView scrollToDate:date options:MGCDayPlannerScrollDate animated:YES];
        
        //update the bottom label
        self.detailsLabel.text = [self.detailsDateFormater stringFromDate:date];
    }
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MGCCalendarHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case PreviousWeekSection://left section
            cell.date = [self.previousWeekDates objectAtIndex:indexPath.row];
            break;
            
        case CurrentWeekSection://central section
            cell.date = [self.currentWeekDates objectAtIndex:indexPath.row];
            break;
            
        case NextWeekSection://right section
            cell.date = [self.nextWeekDates objectAtIndex:indexPath.row];
            break;
    }
    
    cell.pastDateColor = self.dateTextColor;
    cell.dayTextColor = self.dayTextColor;
    cell.selectedDayTextColor = self.selectedDayTextColor;
    cell.selectedDayBackgroundColor = self.selectedDayBackgroundColor;
    cell.weekendColor = self.weekendColor;
    cell.todayColor = self.accentColor;
    cell.dayBackgroundColor = self.headerBackgroundColor;
    cell.dayNameLabelFont = self.dayNameFont;
    cell.dayNumberLabelFont = self.dayNumberFont;
    cell.dayNumberLabelFontSelected = self.dayNumberFontSelected;
    [cell layoutSubviews];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 3; //3 weeks. Each section represents one week, left, center and right, they will be updated dynamically with the propper dates
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kNumberOfDaysToDisplay;
}

#pragma mark - UICollectionViewDelegate

//when the user interacts with the header part move the bottom part
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MGCCalendarHeaderCell *cell = (MGCCalendarHeaderCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self selectDate:cell.date];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSDate *newDate = [self.currentWeekDates objectAtIndex:self.selectedDateIndex];
    
    if(self.contentOffset.x > self.previousContentOffset.x){
        //the user scrolled to the left moving to the next week
        newDate = [self.nextWeekDates objectAtIndex:self.selectedDateIndex];
    }
    else if (self.contentOffset.x < self.previousContentOffset.x){
        //the user scrolled to the right moving to the previous week
        newDate = [self.previousWeekDates objectAtIndex:self.selectedDateIndex];
    }
    
    //small visual trick to provide the feeling of infinite scrolling, actually is reseting the position without animation
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:CurrentWeekSection] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    [self selectDate:newDate];
    
}

@end
