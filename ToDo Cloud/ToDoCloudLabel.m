//
//  ToDoCloudLabel.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudLabel.h"

@implementation ToDoCloudLabel

@synthesize visualCenter;

-(id)initWithFrame:(CGRect)frame visualCenter:(CGPoint)visualCenter {
    self = [self initWithFrame:frame];
    self.visualCenter = visualCenter;
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// When a touch starts, get the current location in the view
	currentPoint = [[touches anyObject] locationInView:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Get active location upon move
	CGPoint activePoint = [[touches anyObject] locationInView:self];
    
	// Determine new point based on where the touch is now located
	CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
                                   self.center.y + (activePoint.y - currentPoint.y));
    
    CGFloat xDist = (self.visualCenter.x - self.center.x);
    CGFloat yDist = (self.visualCenter.y - self.center.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    CGFloat fontSize = 20 - distance/15.5;
    if(fontSize < 8.0){
        fontSize = 8.0;
    }
    UIFont *newFont = [UIFont systemFontOfSize:fontSize];
    CGSize newSize = [self.text sizeWithFont:newFont];
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newSize.width,
                            newSize.height);
    self.font = newFont;
	
    //--------------------------------------------------------
	// Make sure we stay within the bounds of the parent view
	//--------------------------------------------------------
    float midPointX = CGRectGetMidX(self.bounds);
	// If too far right...
    if (newPoint.x > self.superview.bounds.size.width  - midPointX)
        newPoint.x = self.superview.bounds.size.width - midPointX;
	else if (newPoint.x < midPointX) 	// If too far left...
        newPoint.x = midPointX;
    
	float midPointY = CGRectGetMidY(self.bounds);
    // If too far down...
	if (newPoint.y > self.superview.bounds.size.height  - midPointY)
        newPoint.y = self.superview.bounds.size.height - midPointY;
	else if (newPoint.y < midPointY)	// If too far up...
        newPoint.y = midPointY;
    
	// Set new center location
	self.center = newPoint;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%d",touches.count);
}
- (void) moveToCenter {
    self.center = self.visualCenter;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
