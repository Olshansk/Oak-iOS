//
//  QuestionsViewController.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import "QuestionsViewController.h"
#import "CourseObject.h"
#import "QuestionView.h"
#import "TableHeaderView.h"
#import "ODRefreshControl.h"

#import "UIView+SwipeTransitionLeftRight.h"
#import "UIColor+HexToRGB.h"
#import "UITableViewCell+ClearForReuse.h"
#import "NSURL+Parameters.h"
#import "QuestionObject.h"
#import "AmbientNotificationView.h"

#define QUESTION_ERROR NSLocalizedString(@"Error While Retrieving Questions", @"Error While Retrieving Questions")
#define RESOLVE_ERROR NSLocalizedString(@"Error While Marking Question", @"Error While Marking Question")
#define VOTE_ERROR NSLocalizedString(@"Error While Sending Vote", @"Error While Sending Vote")

#define NETWORK_ERROR NSLocalizedString(@"No Network Connection", @"No Network Connection")

#define TOP_STRING NSLocalizedString(@"Top Question", @"Top Question")
#define RISING_STRING NSLocalizedString(@"Rising Questions", @"Rising Questions")
#define PLACEHOLDER_QUESTION_TEXT NSLocalizedString(@"New Question", @"New Question")

#define ACCESSORY_VIEW_HEIGHT 40.0f

#define QUESTION_REFRESH_TIME 20.0f

#define TOP_HEADER_BACKGROUND_VIEW_HEIGHT 200.0f

@implementation QuestionsViewController
{
    UITableView *questionTableView;
    
    UITextField *submitQuestionTextView; //This text field resigns the first responder when a tableview row is clicked or if the tableview is ever dragged (should account for all resign first responder situations) Also note that this text view is only use to call on a first responder
    
    TableHeaderView *topHeaderView;
    TableHeaderView *risingHeaderView;
    
    UIBarButtonItem *submitQuestionBarButtonItem;
    
    KeyboardAccessoryTextView *accessoryView;
    
    ODRefreshControl *refreshControl;
    
    NSTimer *refreshTimer;
    
    AmbientNotificationView *ambientNotification;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)prepareForUseWithCourse:(CourseObject*)course
{
    [self setCourse:course];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval: QUESTION_REFRESH_TIME target: self selector: @selector(dropViewDidBeginRefreshing:) userInfo: nil repeats: YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateQuestionList:) name:DidFinishUpdatingQuestionListNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendQuestionResolve:) name:DidFinishSendingQuestionResolveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendQuestionVote:) name:DidFinishSendingQuestionVoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionError:) name:QuestionObjectNetworkConnectionError object:nil];
}

-(void)stopCourseUse
{
    [refreshTimer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFinishUpdatingQuestionListNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFinishSendingQuestionResolveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidFinishSendingQuestionVoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QuestionObjectNetworkConnectionError object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarController.navigationItem setRightBarButtonItem:submitQuestionBarButtonItem];
    
    [questionTableView setFrame:self.view.frame];
    [questionTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionError:) name:CourseObjectNetworkConnectionError object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.navigationItem setRightBarButtonItem:nil];
    
    [self resignFirstResponders];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CourseObjectNetworkConnectionError object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    accessoryView = [[KeyboardAccessoryTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ACCESSORY_VIEW_HEIGHT)];
    [accessoryView setDelegate:self];
    
    submitQuestionTextView = [[UITextField alloc] initWithFrame:CGRectZero];
    submitQuestionTextView.inputAccessoryView = accessoryView;
    
    submitQuestionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(submitQuestion:)];

    questionTableView = [[UITableView alloc] init];
    [questionTableView setDataSource:self];
    [questionTableView setDelegate:self];
    [questionTableView setSeparatorColor:[UIColor colorWithHexString:SEPARATOR_COLOR]];
    [questionTableView setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
    [questionTableView setFrame:self.view.frame];
    
    UIView *topHeaderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -1 * TOP_HEADER_BACKGROUND_VIEW_HEIGHT, self.view.frame.size.width, TOP_HEADER_BACKGROUND_VIEW_HEIGHT)];
    [topHeaderBackgroundView setBackgroundColor:[UIColor colorWithHexString:LIGHT_GRAY_BACKGROUND_COLOR]];
    [questionTableView addSubview:topHeaderBackgroundView];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:questionTableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
    
    topHeaderView = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_VIEW_HEIGHT) andLabelText:TOP_STRING];
    risingHeaderView = [[TableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_VIEW_HEIGHT) andLabelText:RISING_STRING];
    
    ambientNotification = [[AmbientNotificationView alloc] init];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponders)];
    [topHeaderBackgroundView addGestureRecognizer:tapGesture];
    [risingHeaderView addGestureRecognizer:tapGesture];
    [questionTableView addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView: NO];
//    [questionTableView endEditing:YES];
    
    [self.view addSubview:submitQuestionTextView];
    [self.view addSubview:questionTableView];
}

-(void)didUpdateQuestionList:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([[dict allKeys] containsObject:ERROR_KEY]) {
        [ambientNotification showAmbientNotificationofType:AmbientNotificationError WithMessage:QUESTION_ERROR inView:self.view andHideAfterwards:YES];
    } else {
        [questionTableView reloadData];
    }
    [refreshControl endRefreshing];
    
}

-(void)didSendQuestionResolve:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([[dict allKeys] containsObject:ERROR_KEY]) {
        [ambientNotification showAmbientNotificationofType:AmbientNotificationError WithMessage:RESOLVE_ERROR inView:self.view andHideAfterwards:YES];
    } else {
        [questionTableView reloadData];
    }
}

-(void)didSendQuestionVote:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    if ([[dict allKeys] containsObject:ERROR_KEY]) {
        [ambientNotification showAmbientNotificationofType:AmbientNotificationError WithMessage:VOTE_ERROR inView:self.view andHideAfterwards:YES];
    } else {
        [questionTableView reloadData];
    }
}

-(void)networkConnectionError:(NSNotification *)notification
{
    [refreshControl endRefreshing];
    [ambientNotification showAmbientNotificationofType:AmbientNotificationNetworkError WithMessage:NETWORK_ERROR inView:self.view andHideAfterwards:YES];
}


-(void)dropViewDidBeginRefreshing:(id)sender
{
    [_course retrieveQuestionList];
}

-(void)resignFirstResponders
{
    if ([submitQuestionTextView isFirstResponder]) {
        [submitQuestionTextView resignFirstResponder];
    }
    else if ([accessoryView.textView isFirstResponder]) {
        [accessoryView.textView resignFirstResponder];
    }
}

- (void) submitQuestion:(id)sender
{
    [submitQuestionTextView becomeFirstResponder];
    [accessoryView.textView becomeFirstResponder];
    [submitQuestionTextView resignFirstResponder];
}

-(void)setSeparatorColor //Disables separator when there are no questions
{
    if ([_course.topQuestions count] == 0 && [_course.otherQuestions count] == 0) {
        [questionTableView setSeparatorColor:[UIColor clearColor]];
    } else {
        [questionTableView setSeparatorColor:[UIColor colorWithHexString:SEPARATOR_COLOR]];
    }
}

#pragma mark KeyboardAccessoryTextViewDelegate

-(void) didSubmitQuestion:(NSString*)question
{
    [_course submitQuestion:question];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self setSeparatorColor];
    if (section == 0)
        return [_course.topQuestions count];
    else 
        return [_course.otherQuestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionCell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"QuestionCell"];
    } else {
        [UITableViewCell clearCellContentViewForReuse:cell];
    }
    
    QuestionObject *questionObj;
    
    if ([indexPath section] == 0) {
        questionObj = [_course.topQuestions objectAtIndex:[indexPath row]];
    } else {
        questionObj = [_course.otherQuestions objectAtIndex:[indexPath row]];
    }
    
    QuestionView *view = [[QuestionView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, CELL_HEIGHT) andQuestionObject:questionObj];
    [cell.contentView addSubview:view];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setSelected:NO];
    
    return cell;
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignFirstResponders];
    
    return indexPath;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.02f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return topHeaderView;
    else
        return risingHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_VIEW_HEIGHT;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignFirstResponders];
}

#pragma mark SwipeResponders

-(void) swipeRight:(id)sender
{
    NSInteger selectedIndex = [self.tabBarController selectedIndex];
    
    UIView *fromView = self.tabBarController.selectedViewController.view;
    UIView *toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex - 1] view];
    
    [UIView swipeFromView:fromView toView:toView duration:0.5f options:UIViewAnimationOptionSwipeRight completion:^(BOOL finished) {
        [self.tabBarController setSelectedIndex:selectedIndex - 1];
    }];
}

@end
