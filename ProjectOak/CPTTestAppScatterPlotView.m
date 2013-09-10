//
//  CPTTestAppScatterPlotView.m
//  CPTTestApp-iPhone
//
//  Created by Brad Larson on 5/11/2009.
//

#import "CPTTestAppScatterPlotView.h"
#import "CourseObject.h"
#import "UIColor+HexToRGB.h"

#define GRAPH_PADDING 10.0f
#define ARC4RANDOM_MAX 0x100000000

#define X_RANGE 20
@implementation CPTTestAppScatterPlotView
{
    CPTXYGraph *graph;
    CPTGraphHostingView *hostingView;
    NSTimer *countdownTimer;
    CGFloat xPos;
}
@synthesize dataForPlot;

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Initialization and teardown

-(id)init
{
    self = [super init];
    if (self) {
        graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
        hostingView = [[CPTGraphHostingView alloc] init];
        [hostingView setCollapsesLayers:NO]; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
        [hostingView setHostedGraph:graph];
        [hostingView setUserInteractionEnabled:NO];
        [self addSubview:hostingView];
        
        [graph setPaddingLeft:0];
        [graph setPaddingTop:0];
        [graph setPaddingRight:0];
        [graph setPaddingBottom:0];
        
        // Setup plot space
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
        xPos = (-1 * X_RANGE - 1);
        [plotSpace setXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xPos) length:CPTDecimalFromFloat(X_RANGE)]];
        [plotSpace setYRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(100.0)]];
        
        CPTMutableLineStyle *axisLineStyle = [CPTLineStyle lineStyle];
        axisLineStyle.lineColor = [CPTColor clearColor];
        
        CPTMutableLineStyle *gridLineStyle = [CPTLineStyle lineStyle];
        gridLineStyle.lineColor = [CPTColor whiteColor];
        
        CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
        textStyle.color = [CPTColor clearColor];
        
        // Axes
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
        CPTXYAxis *x = axisSet.xAxis;
        [x setAxisLineStyle:axisLineStyle];
        [x setMajorGridLineStyle: gridLineStyle];
        [x setMinorGridLineStyle: gridLineStyle];
        [x setMajorIntervalLength: CPTDecimalFromString(@"1")];
        [x setMinorTickLineStyle:axisLineStyle];
        [x setLabelTextStyle:textStyle];
        [x setMajorTickLineStyle:axisLineStyle];
        [x setMinorTicksPerInterval:0];
        [x setOrthogonalCoordinateDecimal: CPTDecimalFromString(@"1")];
        
        CPTXYAxis *y = axisSet.yAxis;
        [y setAxisLineStyle:axisLineStyle];
        [y setMajorGridLineStyle: gridLineStyle];
        [y setMinorGridLineStyle: gridLineStyle];
        [y setMajorIntervalLength: CPTDecimalFromString(@"20")];
        [y setLabelTextStyle:textStyle];
        [y setMinorTickLineStyle:axisLineStyle];
        [y setMajorTickLineStyle:axisLineStyle];
        [y setMinorTicksPerInterval:1];
        [y setOrthogonalCoordinateDecimal: CPTDecimalFromString(@"1")];
        
        
        CGFloat red, green, blue, alpha;
        UIColor *color = [UIColor colorWithHexString:LOGO_CYAN];
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        [lineStyle setMiterLimit: 3.0f];
        [lineStyle setLineWidth: 2.0f];
        [lineStyle setLineColor: [CPTColor colorWithCGColor:[color CGColor]]];
        
        [graph setBorderLineStyle:gridLineStyle];
        
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init] ;
        [dataSourceLinePlot setDataLineStyle: lineStyle];
        [dataSourceLinePlot setIdentifier: @"Plot"];
        [dataSourceLinePlot setDataSource: self];

        CPTColor *startColor = [CPTColor colorWithComponentRed:red green:green blue:blue alpha:0.5f];
        CPTColor *endColor = [CPTColor colorWithComponentRed:red green:green blue:blue alpha:0.5f];
        CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:startColor endingColor:endColor];
        [areaGradient setAngle: -90.0f];
        CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
        [dataSourceLinePlot setAreaFill: areaGradientFill];
        [dataSourceLinePlot setAreaBaseValue: CPTDecimalFromString(@"0")];
        
        [graph addPlot:dataSourceLinePlot];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [hostingView setFrame:CGRectMake(GRAPH_PADDING, frame.origin.x + GRAPH_PADDING, frame.size.width - GRAPH_PADDING * 2, frame.size.height - GRAPH_PADDING * 2)];
//    [hostingView setFrame:CGRectInset (frame, GRAPH_PADDING, GRAPH_PADDING)];
}

-(void)shiftGraph
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    xPos += 1;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xPos) length:CPTDecimalFromFloat(X_RANGE)];
    
    [graph reloadData];
    [graph setNeedsDisplay];

}

-(void)resetAxis
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    xPos = (-1 * X_RANGE - 1);
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xPos) length:CPTDecimalFromFloat(X_RANGE)];
    
    [graph reloadData];
    [graph setNeedsDisplay];
    
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = [[dataForPlot objectAtIndex:index] valueForKey:key];
    return num;
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;

    NSNumberFormatter *formatter = axis.labelFormatter;
    CGFloat labelOffset          = axis.labelOffset;
    NSDecimalNumber *zero        = [NSDecimalNumber zero];

    NSMutableSet *newLabels = [NSMutableSet set];

    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle;

        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            if ( !positiveStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                positiveStyle  = newStyle;
            }
            theLabelTextStyle = positiveStyle;
        }
        else {
            if ( !negativeStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle  = newStyle;
            }
            theLabelTextStyle = negativeStyle;
        }

        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];

        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;

        [newLabels addObject:newLabel];
    }

    axis.axisLabels = newLabels;

    return NO;
}

-(void)updateGraph
{
    [self shiftGraph];
}

-(void)prepareForUseWithCourse:(CourseObject*)course
{
    [countdownTimer invalidate];
    [self resetAxis];
    [self setCourse:course];
    [self setDataForPlot:_course.plotData];
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f target: _course selector: @selector(updatePlotData) userInfo: nil repeats: YES];
}

-(void)stopCourseUse
{
    [countdownTimer invalidate];
}


@end
