//
//  ToDoCloudLabel.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudLabel.h"

@implementation ToDoCloudLabel

@synthesize visualCenter, velocity;

-(id) initWithFrame:(CGRect)frame visualCenter:(CGPoint)visualCenter {
    self = [self initWithFrame:frame];
    self.visualCenter = visualCenter;
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        velocity = CGPointMake(0.0, 0.0);
    }
    return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// When a touch starts, get the current location in the view
	currentPoint = [[touches anyObject] locationInView:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	// Get active location upon move
	CGPoint activePoint = [[touches anyObject] locationInView:self];
    
	// Determine new point based on where the touch is now located
	CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
                                   self.center.y + (activePoint.y - currentPoint.y));
    [self boundedMoveToNewCenter:newPoint];
    
    [self checkAndUpdateOverlappingLabels];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint endPoint = [[touches anyObject] locationInView:self.superview];
    CGFloat tops = [self.superview viewWithTag:1].frame.origin.y - 8.0;
    if(CGRectContainsPoint([self.superview viewWithTag:1].frame, endPoint)) {
        [self removeFromSuperview];
        NSLog(@"Deleted: %@", self.text);
    } else if(CGRectContainsPoint([self.superview viewWithTag:2].frame, endPoint)) {
        [self removeFromSuperview];
        //TODO: store the completed ones somewhere. WHERE? who knows!
        NSLog(@"Completed: %@", self.text);
    } else if(self.frame.origin.y + self.frame.size.height > tops) {
        //bounce up!
        CGPoint newCenter = CGPointMake(self.center.x, tops - (self.frame.size.height/2.0));
        CGFloat duration = 1.0 - (self.center.y - newCenter.y)/55.0;
        [UIView animateWithDuration:0.25 + 0.25*duration
                              delay:0
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             self.center = newCenter;
                         } 
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
    }
}

- (void) moveToCenter {
    [self boundedMoveToNewCenter:visualCenter];
    [self checkAndUpdateOverlappingLabels];
}

- (void)checkAndUpdateOverlappingLabels {
    //Ok you shouldn't have to do that ...
    [self checkAndUpdateOverlappingLabelsExcluding:[[NSMutableArray alloc] init]];
}

- (void)checkAndUpdateOverlappingLabelsExcluding:(NSMutableArray *)exclude {
    int length = [self.superview.subviews count];
    int count=0;
    while(count < length) {
        UIView *element = [self.superview.subviews objectAtIndex:count];
        count += 1;
        if([element isKindOfClass: ToDoCloudLabel.class]) {
            ToDoCloudLabel *checkLabel = (ToDoCloudLabel *)element;
            // Don't compare to itself delete or complete views.
            if(checkLabel != self && checkLabel.tag != 1 && checkLabel.tag != 2 &&
               ([exclude count] == 0 || ![exclude containsObject:checkLabel]) &&
               CGRectIntersectsRect(self.frame, checkLabel.frame)) {
                // Push the overlapping label out
                CGPoint newCenter = checkLabel.center;
                newCenter.x += velocity.x;
                newCenter.y += velocity.y;
                // If there's no pushing, overlapping rectangles repel each other evenly
                // TODO!
                
                // also: what if moving the label hit a wall
                
                
                [checkLabel boundedMoveToNewCenter:newCenter];
                
                // add checklabel to the array and call it again.
                [exclude addObject:checkLabel];
                [checkLabel checkAndUpdateOverlappingLabelsExcluding:exclude];
            }
        }
    }
}


- (void)boundedMoveToNewCenter:(CGPoint)newPoint {
    BOOL hitBoundry = false;
    //--------------------------------------------------------
	// Make sure we stay within the bounds of the parent view
	//--------------------------------------------------------
    float midPointX = CGRectGetMidX(self.bounds);
	// If too far right...
    if (newPoint.x > self.superview.bounds.size.width  - midPointX) {
        newPoint.x = self.superview.bounds.size.width - midPointX;
        hitBoundry = true;
    } else if (newPoint.x < midPointX) {
        // If too far left...
        newPoint.x = midPointX;
        hitBoundry = true;
    }
    
	float midPointY = CGRectGetMidY(self.bounds);
    // If too far down...
	if (newPoint.y > self.superview.bounds.size.height  - midPointY) {
        newPoint.y = self.superview.bounds.size.height - midPointY;
        hitBoundry = true;
    } else if (newPoint.y < midPointY) {
        // If too far up...
        newPoint.y = midPointY;
        hitBoundry = true;
    }
    velocity = CGPointMake(newPoint.x - self.center.x,newPoint.y - self.center.y);
    
	// Set new center location
	self.center = newPoint;
    // update the font size
    [self updateFontSize];
}

- (void)updateFontSize {
    CGFloat xDist = (self.visualCenter.x - self.center.x);
    CGFloat yDist = (self.visualCenter.y - self.center.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    CGFloat fontSize = MAXIMUM_FONT_SIZE - distance/FONT_RESIZE_FACTOR;
    if(fontSize < MINIMUM_FONT_SIZE){
        fontSize = MINIMUM_FONT_SIZE;
    }
    
    UIFont *newFont = [UIFont fontWithName:@"GillSans-Light" size:fontSize];
    CGSize newSize = [self.text sizeWithFont:newFont];
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newSize.width,
                            newSize.height);
    self.font = newFont;
}
@end
