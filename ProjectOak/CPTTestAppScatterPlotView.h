//
//  CPTTestAppScatterPlotView.h
//  CPTTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@class CourseObject;

@interface CPTTestAppScatterPlotView: UIView <CPTPlotDataSource, CPTAxisDelegate>

@property (readwrite, retain, nonatomic) NSMutableArray *dataForPlot;
@property (nonatomic, strong) CourseObject *course;

-(void)updateGraph;
-(void)prepareForUseWithCourse:(CourseObject*)course;
-(void)stopCourseUse;

@end
