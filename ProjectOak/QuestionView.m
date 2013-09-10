//
//  QuestionView.m
//  ProjectOak
//
//  Created by Daniel Olshansky on 2012-12-25.
//  Copyright (c) 2012 Daniel Olshansky. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "QuestionView.h"
#import "QuestionObject.h"
#import "TriangleView.h"
#import "UIColor+HexToRGB.h"
#import "NSString+TimeStamp.h"

#define SIDE_MARGIN_FOR_VOTING 10.0f
#define WIDTH_FOR_VOTING 30.0f
#define SIDE_MARGIN_FOR_CHECK_BOX 15.0f
#define CHECK_BOX_WIDTH 30.0f
#define TRIANGLE_VERTICAL_MARGINS 5.0f
#define TRIANGLE_HORIZONTAL_MARGINS 2.0f
#define CHECK_MARK_EXTRA_OVER_BOX 3.0f
#define VERTICAL_MARGIN_FOR_QUESTION_TEXT 3.0f


#define QUESTION_DETAIL_TEXT NSLocalizedString(@"%@ ago", @"%@ ago")

@implementation QuestionView
{
    UIButton *upVoteButton;
    UIButton *downVoteButton;
    UILabel *upDownVoteCountLabel;
    UILabel *questionTextLabel;
    UILabel *questionDetailLabel;
    UIButton *checkMarkButton;
    
    TriangleView *upVoteTriangle;
    TriangleView *downVoteTriangle;
    
}

- (id)initWithFrame:(CGRect)frame andQuestionObject:(QuestionObject*)questionObject
{
    self = [super initWithFrame:frame];
    if (self) {
        _questionObject = questionObject;
        
        upDownVoteCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_MARGIN_FOR_VOTING, frame.size.height/3.0f, WIDTH_FOR_VOTING, frame.size.height/3.0f)];
        [upDownVoteCountLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [upDownVoteCountLabel setTextAlignment:NSTextAlignmentCenter];
        [upDownVoteCountLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
        
        upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [upVoteButton setFrame:CGRectMake(SIDE_MARGIN_FOR_VOTING + TRIANGLE_HORIZONTAL_MARGINS, TRIANGLE_VERTICAL_MARGINS, WIDTH_FOR_VOTING - TRIANGLE_HORIZONTAL_MARGINS * 2, frame.size.height/3.0f - TRIANGLE_VERTICAL_MARGINS)];
        [upVoteButton addTarget:self action:@selector(upVoteAction:) forControlEvents:UIControlEventTouchUpInside];
        [upVoteButton addTarget:self action:@selector(upVoteActionActivated:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [upVoteButton addTarget:self action:@selector(upVoteActionDeactivated:) forControlEvents:UIControlEventTouchDragExit];
        upVoteTriangle = [[TriangleView alloc] initWithFrame:upVoteButton.bounds withTriangleDirection:UIViewTrianglePointUp];
        [upVoteTriangle setUserInteractionEnabled:NO];
        [upVoteTriangle setState:[questionObject didUpVote] ? UIViewTriangleStateSelected : UIViewTriangleStateNotSelected];
        [upVoteButton addSubview:upVoteTriangle];
        
        downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downVoteButton setFrame:CGRectMake(SIDE_MARGIN_FOR_VOTING + TRIANGLE_HORIZONTAL_MARGINS, frame.size.height * 2.0f / 3.0f, WIDTH_FOR_VOTING - TRIANGLE_HORIZONTAL_MARGINS * 2, frame.size.height/3.0f  - TRIANGLE_VERTICAL_MARGINS)];
        [downVoteButton addTarget:self action:@selector(downVoteAction:) forControlEvents:UIControlEventTouchUpInside];
        [downVoteButton addTarget:self action:@selector(downVoteActionActivated:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [downVoteButton addTarget:self action:@selector(downVoteActionDeactivated:) forControlEvents:UIControlEventTouchDragExit];
        downVoteTriangle = [[TriangleView alloc] initWithFrame:upVoteButton.bounds withTriangleDirection:UIViewTrianglePointDown];
        [downVoteTriangle setUserInteractionEnabled:NO];
        [upVoteButton addTarget:self action:@selector(upVoteActionDeactivated:) forControlEvents:UIControlEventTouchDragExit];
        [downVoteTriangle setState:[questionObject didDownVote] ? UIViewTriangleStateSelected : UIViewTriangleStateNotSelected];
        [downVoteButton addSubview:downVoteTriangle];
        
        checkMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkMarkButton setFrame:CGRectMake(frame.size.width - SIDE_MARGIN_FOR_CHECK_BOX - CHECK_BOX_WIDTH, frame.size.height/2.0f - CHECK_BOX_WIDTH/2.0f, CHECK_BOX_WIDTH, CHECK_BOX_WIDTH)];
        [checkMarkButton setBackgroundColor:[UIColor clearColor]];
        [checkMarkButton setImage:[UIImage imageNamed:@"CheckBox"] forState:UIControlStateNormal];
        [checkMarkButton setImage:[UIImage imageNamed:@"CheckMarked"] forState:UIControlStateSelected];
        [checkMarkButton addTarget:self action:@selector(markAsResolved:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat xPos = upDownVoteCountLabel.frame.origin.x + upDownVoteCountLabel.frame.size.width + SIDE_MARGIN_FOR_VOTING;
        CGFloat width = frame.size.width - xPos - SIDE_MARGIN_FOR_CHECK_BOX * 2 - CHECK_BOX_WIDTH;
        
        questionDetailLabel = [[UILabel alloc] init];
        [questionDetailLabel setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_DETAILED_TITLE_FONT_SIZE]];
        [questionDetailLabel setNumberOfLines:1];
        [questionDetailLabel setTextColor:[UIColor colorWithHexString:LIGHT_GRAY_TEXT_COLOR]];
        [questionDetailLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
        CGSize detailSize = [@"AnyText" sizeWithFont:questionDetailLabel.font];
        [questionDetailLabel setFrame:CGRectMake(xPos, frame.size.height - detailSize.height - VERTICAL_MARGIN_FOR_QUESTION_TEXT, width, detailSize.height)];
        
        questionTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos, VERTICAL_MARGIN_FOR_QUESTION_TEXT, width ,frame.size.height - detailSize.height - VERTICAL_MARGIN_FOR_QUESTION_TEXT * 3)];
        [questionTextLabel setFont:[UIFont systemFontOfSize:TABLE_VIEW_CELL_TITLE_FONT_SIZE]];
        [questionTextLabel setNumberOfLines:0];
        [questionTextLabel setTextColor:[UIColor colorWithHexString:GRAY_TEXT_COLOR]];
        [questionTextLabel setBackgroundColor:[UIColor colorWithHexString:GRAY_BACKGROUND_COLOR]];
        
        [self updateView];
        
        [self addSubview:upVoteButton];
        [self addSubview:downVoteButton];
        [self addSubview:upDownVoteCountLabel];
        [self addSubview:questionTextLabel];
        [self addSubview:questionDetailLabel];
        [self addSubview:checkMarkButton];
    }
    return self;
}

-(void)updateView
{
    [upDownVoteCountLabel setText:[NSString stringWithFormat:@"%d",[_questionObject numOfUpVotes]]];
    [questionDetailLabel setText:[NSString stringWithFormat:QUESTION_DETAIL_TEXT,[NSString generateTimeStamp:_questionObject.timeCreated]]];
    [questionTextLabel setText:[_questionObject questionText]];
    [checkMarkButton setSelected:[_questionObject didMarkAsResolved]];
    
    if([_questionObject didDownVote]) {
        [downVoteTriangle setState : UIViewTriangleStateSelected];
        [upVoteTriangle setState : UIViewTriangleStateNotSelected];
    } else if ([_questionObject didUpVote]){
        [downVoteTriangle setState : UIViewTriangleStateNotSelected];
        [upVoteTriangle setState : UIViewTriangleStateSelected];
    } else {
        [downVoteTriangle setState : UIViewTriangleStateNotSelected];
        [upVoteTriangle setState : UIViewTriangleStateNotSelected];
    }
    
    [upVoteTriangle setNeedsDisplay];
    [downVoteTriangle setNeedsDisplay];

}

#pragma mark ButtonActions

-(void) downVoteActionDeactivated:(id)sender
{
    if (downVoteTriangle.state == UIViewTriangleStateNotSelectedPressed)
        [downVoteTriangle setState: UIViewTriangleStateNotSelected];
    else
        [downVoteTriangle setState: UIViewTriangleStateSelected];
    
    [downVoteTriangle setNeedsDisplay];
}

-(void) upVoteActionDeactivated:(id)sender
{
    if (upVoteTriangle.state == UIViewTriangleStateNotSelectedPressed)
        [upVoteTriangle setState: UIViewTriangleStateNotSelected];
    else
        [upVoteTriangle setState: UIViewTriangleStateSelected];
    
    [upVoteTriangle setNeedsDisplay];
}

-(void) downVoteActionActivated:(id)sender
{
    if (downVoteTriangle.state == UIViewTriangleStateNotSelected)
        [downVoteTriangle setState: UIViewTriangleStateNotSelectedPressed];
    else
        [downVoteTriangle setState: UIViewTriangleStateSelectedPressed];
    
    [downVoteTriangle setNeedsDisplay];
}

-(void) upVoteActionActivated:(id)sender
{
    if (upVoteTriangle.state == UIViewTriangleStateNotSelected)
        [upVoteTriangle setState: UIViewTriangleStateNotSelectedPressed];
    else
        [upVoteTriangle setState: UIViewTriangleStateSelectedPressed];
    
    [upVoteTriangle setNeedsDisplay];
}

-(void)downVoteAction:(id)sender
{
    [_questionObject setNumOfUpVotes: [_questionObject didDownVote] ? [_questionObject numOfUpVotes] + 1 : [_questionObject didUpVote] ? [_questionObject numOfUpVotes] - 2 : [_questionObject numOfUpVotes] - 1];
    
    [_questionObject setDidDownVote:[_questionObject didDownVote] ? NO : YES];
    [_questionObject setDidUpVote:NO];
    
    [self updateView];
    
    [_questionObject upOrDownVoteRequest];
}

-(void)upVoteAction:(id)sender
{
    [_questionObject setNumOfUpVotes: [_questionObject didUpVote] ? [_questionObject numOfUpVotes] -1 : [_questionObject didDownVote] ? [_questionObject numOfUpVotes] + 2 : [_questionObject numOfUpVotes] + 1];
    
    [_questionObject setDidDownVote:NO];
    [_questionObject setDidUpVote:[_questionObject didUpVote] ? NO : YES];
    
    [self updateView];
    
    [_questionObject upOrDownVoteRequest];
    
}

-(void) markAsResolved:(id)sender
{
    [_questionObject setDidMarkAsResolved:[_questionObject didMarkAsResolved] ? NO : YES];
    
    [self updateView];
    
    [_questionObject resolveQuestionRequest];
}

@end
