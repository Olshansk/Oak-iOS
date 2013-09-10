//
//  CoursesViewController.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CoursesViewController.h"
#import "QuestionsViewController.h"
#import "UMeterViewController.h"
#import "CourseObject.h"
#import "TableHeaderView.h"
#import "CourseListObject.h"
#import "ODRefreshControl.h"
#import "AmbientNotificationView.h"

#import "UIColor+HexToRGB.h"
#import "UINavigationController+CustomAnimations.h"

#define ADDING_COURSE_TEXT NSLocalizedString(@"Trying To Add Course", @"Trying To Add Course")
#define ADDED_COURSE_SUCCESSFULLY NSLocalizedString(@"Course Added Successfully", @"Course Added Successfully")
#define ADDED_COURSE_ERROR NSLocalizedString(@"Was Not Able To Add Course", @"Was Not Able To Add Course")

#define JOINING_COURSE_TEXT NSLocalizedString(@"Trying To Join Course", @"Trying To Join Course")
#define JOINING_COURSE_SUCCESSFULLY NSLocalizedString(@"Course Joined Successfully", @"Course Joined Successfully")
#define JOINING_COURSE_ERROR NSLocalizedString(@"Was Not Able To Join Course", @"Was Not Able To Join Course")

#define NETWORK_ERROR NSLocalizedString(@"No Network Connection", @"No Network Connection")

#define PREVIOUS_STRING NSLocalizedString(@"Courses Previously Joined", @"Courses Previously Joined")
#define AVAILABLE_STRING NSLocalizedString(@"Available Courses", @"Available Courses")
#define PEOPLE_IN_ROOM_STRING NSLocalizedString(@"%d People in Room",@"%d People in Room")

#define COURSES_STRING NSLocalizedString(@"Courses",@"Courses")
#define QUESTIONS_STRING NSLocalizedString(@"Questions",@"Questions")
#define UMETER_STRING NSLocalizedString(@"UMeter",@"UMeter")

#define TOP_HEADER_BACKGROUND_VIEW_HEIGHT 200.0f

@implementation CoursesViewController
{    
    UITableView *coursesTableView;
    
    UITabBarController *tabController;
    
    TableHeaderView *previousHeaderView;
    TableHeaderView *availableHeaderView;
    
    QuestionsViewController *questions;
    UMeterViewController *umeter;
    
    NewCourseView *newCourseView;
    
    ODRefreshControl *refreshControl;
    
    AmbientNotificationView *ambientNotification;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [tabController setSelectedIndex:0];
}

-(void) viewWillAppear:(BOOL)animated
{
    [coursesTableView setFrame:self.view.frame];
    [newCourseView setFrame:self.view.frame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishJoiningNewCourse:) name:DidFinishJoiningCourseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishAddingNewCourse:) name:DidFinishAddingCourseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLoadingCourses:) name:DidFinishLoadingCoursesNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionError:) name:CourseObjectNetworkConnectionError object:nil];
    
    [questions stopCourseUse];
    [umeter stopCourseUse];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFinishJoiningCourseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFinishAddingCourseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFinishLoadingCoursesNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CourseObjectNetworkConnectionError object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:COURSES_STRING];
    
    _courses = [[CourseListObject alloc] init];
    
    questions = [[QuestionsViewController alloc] init];
    [questions setTabBarItem:[[UITabBarItem alloc] initWithTitle:QUESTIONS_STRING image:[UIImage imageNamed:@"QuestionIcon"] tag:1]];
    
    umeter = [[UMeterViewController alloc] init];
    [umeter setTabBarItem:[[UITabBarItem alloc] initWithTitle:UMETER_STRING image:[UIImage imageNamed:@"PlotIcon"] tag:2]];

    tabController = [[UITabBarController alloc] init];
    [tabController setViewControllers:@[umeter,questions]];
    
    newCourseView = [[NewCourseView alloc] initWithSuperView:self.view];
    [newCourseView setDelegate:self];
    
    coursesTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    [coursesTableView setDataSource:self];
    [coursesTableView setDelegate:self];
    [coursesTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [coursesTableView setSeparatorColor:[UIColor colorWithHexString:SEPARATOR_COLOR]];
    [coursesTableView setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
    
    UIView *topHeaderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -1 * TOP_HEADER_BACKGROUND_VIEW_HEIGHT, self.view.frame.size.width, TOP_HEADER_BACKGROUND_VIEW_HEIGHT)];
    [topHeaderBackgroundView setBackgroundColor:[UIColor colorWithHexString:LIGHT_GRAY_BACKGROUND_COLOR]];
    [coursesTableView addSubview:topHeaderBackgroundView];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:coursesTableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    
    previousHeaderView = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_VIEW_HEIGHT) andLabelText:PREVIOUS_STRING];
    availableHeaderView = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_VIEW_HEIGHT) andLabelText:AVAILABLE_STRING];
    
    ambientNotification = [[AmbientNotificationView alloc] init];
    
    UIBarButtonItem *addCourseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCourse:)];
    [self.navigationItem setRightBarButtonItem:addCourseButton];

    [self.view addSubview:coursesTableView];
    
    [_courses loadCourseList];
}

-(void)setSeparatorColor //Disables separator when there are no questions
{
    if ([_courses.previousArray count] == 0 && [_courses.availableArray count] == 0) {
        [coursesTableView setSeparatorColor:[UIColor clearColor]];
    } else {
        [coursesTableView setSeparatorColor:[UIColor colorWithHexString:SEPARATOR_COLOR]];
    }
}

-(void)dropViewDidBeginRefreshing:(id)sender
{
    [_courses loadCourseList];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoursesCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CoursesCell"];
    }
    
    CourseObject *courseObj;
    
    if (indexPath.section == 0) {
        courseObj = [_courses.previousArray objectAtIndex:[indexPath row]];
    } else {
        courseObj = [_courses.availableArray objectAtIndex:[indexPath row]];
    }
    [[cell textLabel] setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_TITLE_FONT_SIZE]];
    [[cell textLabel] setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    [[cell textLabel] setText:courseObj.courseCode];
    
//    [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_DETAILED_TITLE_FONT_SIZE]];
//    [[cell detailTextLabel] setTextColor:[UIColor colorWithHexString:LIGHT_GRAY_TEXT_COLOR]];
//    [[cell detailTextLabel] setText:[NSString stringWithFormat:PEOPLE_IN_ROOM_STRING, courseObj.numOfPeopleInRoom]];
    [cell setSelected:NO];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self setSeparatorColor];
    if (section == 0)
        return [_courses.previousArray count];
    else
        return [_courses.availableArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

#pragma mark UITableViewDelegate

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return previousHeaderView;
    else
        return availableHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CourseObject *courseObj;
    
    if (indexPath.section == 0) {
        courseObj = [_courses.previousArray objectAtIndex:indexPath.row];
        
        [courseObj retrieveQuestionList];
        [questions prepareForUseWithCourse:courseObj];
        [umeter prepareForUseWithCourse:courseObj];
        [courseObj clearPlotData];
        
        [tabController setTitle:courseObj.courseCode];
        [self.navigationController pushViewController:tabController animated:YES];
    } else {
        courseObj = [_courses.availableArray objectAtIndex:indexPath.row];
        
        [newCourseView showNewCourseViewForCourse:courseObj.courseCode];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_VIEW_HEIGHT;
}

#pragma mark Responders

-(void) addCourse:(id)sender
{
    [newCourseView showNewCourseView];
}

#pragma mark NSNotifications

-(void)didFinishLoadingCourses:(NSNotification *)notification
{
    [refreshControl endRefreshing];
    [coursesTableView reloadData];
}

-(void)networkConnectionError:(NSNotification *)notification
{
    [refreshControl endRefreshing];
    [ambientNotification showAmbientNotificationofType:AmbientNotificationNetworkError WithMessage:NETWORK_ERROR inView:self.view andHideAfterwards:YES];
}

-(void)didFinishAddingNewCourse:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([[dict allKeys] containsObject:ERROR_KEY]) {
        [ambientNotification showAmbientNotificationofType:AmbientNotificationError WithMessage:ADDED_COURSE_ERROR inView:self.view andHideAfterwards:YES];
    } else {
        [coursesTableView reloadData];
        [ambientNotification showAmbientNotificationofType:AmbientNotificationSuccess WithMessage:ADDED_COURSE_SUCCESSFULLY inView:self.view andHideAfterwards:YES];
    }
}

-(void)didFinishJoiningNewCourse:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([[dict allKeys] containsObject:ERROR_KEY]) {
        [ambientNotification showAmbientNotificationofType:AmbientNotificationError WithMessage:JOINING_COURSE_ERROR inView:self.view andHideAfterwards:YES];
    } else {
        [coursesTableView reloadData];
        [ambientNotification showAmbientNotificationofType:AmbientNotificationSuccess WithMessage:JOINING_COURSE_SUCCESSFULLY inView:self.view andHideAfterwards:YES];
    }
}

#pragma mark NewCourseViewDelegate

-(void) didJoinCourse:(NSString*)course withPassword:(NSString*)password
{
    [_courses joinCourse:course withPassword:password];
    [ambientNotification showAmbientNotificationofType:AmbientNotificationProcessing WithMessage:JOINING_COURSE_TEXT inView:self.view andHideAfterwards:NO];
}
-(void) didAddCourse:(NSString*)course withPassword:(NSString*)password
{
    [_courses addCourse:course withPassword:password];
    [ambientNotification showAmbientNotificationofType:AmbientNotificationProcessing WithMessage:ADDING_COURSE_TEXT inView:self.view andHideAfterwards:NO];
}

@end
