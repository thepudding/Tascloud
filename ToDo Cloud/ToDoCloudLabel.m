//
//  ToDoCloudLabel.m
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import "ToDoCloudLabel.h"

@implementation ToDoCloudLabel

@synthesize visualCenter, lastPushedDirection, anchor;
////////
// NSCoder implementation
////////
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:@"textKey"];
    [aCoder encodeCGPoint:self.center forKey:@"centerKey"];
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithText: [aDecoder decodeObjectForKey:@"textKey"] center:[aDecoder decodeCGPointForKey:@"centerKey"]];
}

////////
// Initializers
////////
- (id)initAtCenterWithText:(NSString *)text withVisualCenter:(CGPoint)vc {
    self.visualCenter = vc;
    return [self initWithText:text center:vc];
}
- (id)initWithText:(NSString *)text center:(CGPoint)center {
    if (self = [super init]) {
        self.text = text;
        self.center = center;
        self.anchor = [self frameAtPosition:center];
        self.userInteractionEnabled = true;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor colorWithWhite: 0.13 alpha:1];
    }
    return self;
}

////////
// Accessors
////////
- (void)setVisualCenter:(CGPoint)vc {
    visualCenter = vc;
    [self updateFontSize];
}

////////
// Touch Events
////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// When a touch starts, get the current location in the view
	currentPoint = [[touches anyObject] locationInView:self];
}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	// Get active location upon move
	CGPoint activePoint = [[touches anyObject] locationInView:self];
    
	// Determine new point based on where the touch is now located
	CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - currentPoint.x),
                                   self.center.y + (activePoint.y - currentPoint.y));
    [self boundedMoveToNewCenter:newPoint];
    self.anchor = self.frame;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Task Moved" object:self];
    
    //[self.superview updateIntersenctingLabelsOf:self];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // The point in taskField when the touch ended
    CGPoint endPoint = [[touches anyObject] locationInView:self.superview];
    
    CGFloat tops = [self.superview viewWithTag:1].frame.origin.y - 8.0;
    // Check for delete
    if(CGRectContainsPoint([self.superview viewWithTag:1].frame, endPoint)) {
        [self showDeleteActionSheet];
    // Check for Complete
    } else if(CGRectContainsPoint([self.superview viewWithTag:2].frame, endPoint)) {
        [self removeFromSuperview];
        //TODO: store the completed ones somewhere. WHERE? who knows!
        NSLog(@"Completed");
    // Check for bounce
    } else if(self.frame.origin.y + self.frame.size.height > tops) {
        //bounce up!
        [self bounceAwayFromBottom];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Task Move Finished" object:self];
    }
}

// returns the direction that pushedView should be pushed in to remove overlap
- (Direction)pushDirectionFor:(ToDoCloudLabel *)pushedLabel {
    Direction d = {0,0};
    
    if(CGRectIntersectsRect(previousPosition, pushedLabel.frame)) {
        return lastPushedDirection;
    }
    float xVelocity = self.center.x - CGRectGetMidX(previousPosition);
    float yVelocity = self.center.y - CGRectGetMidY(previousPosition);
    if(fabs(xVelocity) - fabs(yVelocity) > 5) {
        return (Direction){signumF(xVelocity), 0};
    } else if (fabs(yVelocity) - fabs(xVelocity) > 5) {
        return (Direction){0, signumF(yVelocity)};
    }
    // differences in centers of two views
    float xDiff = pushedLabel.center.x - CGRectGetMidX(previousPosition);
    float yDiff = pushedLabel.center.y - CGRectGetMidY(previousPosition);
    // A rectangle equal to the prevPos but aligned with pushedView.center on x and y axis respectively
    CGRect xAlign = CGRectOffset(previousPosition, xDiff, 0);
    CGRect yAlign = CGRectOffset(previousPosition, 0, yDiff);
    
    // Push along X if
    if(CGRectIntersectsRect(pushedLabel.frame, xAlign)) {
        d.x = signumF(xDiff);
    // otherwise push along y if
    } else if(CGRectIntersectsRect(pushedLabel.frame, yAlign)) {
        d.y = signumF(yDiff);
    // if they don't overlap at all, just use the direction with more force
    } else {
        if(xVelocity > yVelocity) {
            d.x = signumF(xDiff);
        } else {
            d.y = signumF(yDiff);
        }
    }
    pushedLabel.lastPushedDirection = d;
    return d;
}

- (CGPoint)getShift {
    return CGPointMake(self.center.x - CGRectGetMidX(previousPosition),
                       self.center.y - CGRectGetMidY(previousPosition));
}

////////
// Movement Methods
////////
- (void)moveToCenter {
    [self boundedMoveToNewCenter:visualCenter];
}
- (void)boundedShiftBy:(CGPoint)shiftFactor {
    [self boundedMoveToNewCenter:CGPointMake(self.center.x + shiftFactor.x, self.center.y + shiftFactor.y)];
}
- (void)bounceAwayFromBottom {
    CGFloat tops = [self.superview viewWithTag:1].frame.origin.y - 8.0;
    CGPoint newCenter = CGPointMake(self.center.x, tops - (self.frame.size.height/2.0));
    CGFloat duration = 1.0 - (self.center.y - newCenter.y)/55.0;
    [UIView animateWithDuration:0.25 + 0.25*duration
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.center = newCenter;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Bounce Done!");
                     }];
    [self updateFontSize];
}
// Returns the offset from the desired point
- (void)boundedMoveToNewCenter:(CGPoint)newPoint {
    previousPosition = self.frame;
    //--------------------------------------------------------
	// Make sure we stay within the bounds of the parent view
	//--------------------------------------------------------
    float midPointX = CGRectGetMidX(self.bounds);
	// If too far right...
    if (newPoint.x > self.superview.bounds.size.width  - midPointX) {
        newPoint.x = self.superview.bounds.size.width - midPointX;
    } else if (newPoint.x < midPointX) {
        // If too far left...
        newPoint.x = midPointX;
    }
    
	float midPointY = CGRectGetMidY(self.bounds);
    // If too far down...
	if (newPoint.y > self.superview.bounds.size.height  - midPointY) {
        newPoint.y = self.superview.bounds.size.height - midPointY;
    } else if (newPoint.y < midPointY) {
        // If too far up...
        newPoint.y = midPointY;
    }
    
	// Set new center location
	self.center = newPoint;
    // update the font size
    [self updateFontSize];
}
- (void)snapToAnchor {
    self.bounds = (CGRect){CGPointZero, self.anchor.size};
    [UIView animateWithDuration:0.25
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.frame = anchor;
                         [self updateFontSize];
                     }
                     completion:^(BOOL finished){
                         [self updateFontSize];
                     }];
}
////////
// Resize
////////
- (UIFont *)fontForPosition:(CGPoint)pos {
    CGFloat xDist = (self.visualCenter.x - self.center.x);
    CGFloat yDist = (self.visualCenter.y - self.center.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    
    CGFloat fontSize = MAXIMUM_FONT_SIZE - distance/FONT_RESIZE_FACTOR;
    if(fontSize < MINIMUM_FONT_SIZE){
        fontSize = MINIMUM_FONT_SIZE;
    }
    
    return [UIFont fontWithName:@"GillSans-Light" size:fontSize];
}
- (CGRect)frameAtPosition:(CGPoint)pos {
    UIFont *newFont = [self fontForPosition:self.center];
    CGSize newSize = [self.text sizeWithFont:newFont];
    return CGRectMake(self.center.x - newSize.width/2,
                      self.center.y - newSize.height/2,
                      newSize.width,
                      newSize.height);
}
- (void)updateFontSize {
    UIFont *newFont = [self fontForPosition:self.center];
    CGSize newSize = [self.text sizeWithFont:newFont];
    self.frame = CGRectMake(self.center.x - newSize.width/2,
                            self.center.y - newSize.height/2,
                            newSize.width,
                            newSize.height);
    self.font = newFont;
}
////////
// Delete Dialogue
////////
-(void)showDeleteActionSheet{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"confirm" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.superview];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self removeFromSuperview];
            break;
        case 1:
            [self bounceAwayFromBottom];
            break;
    }
}
@end
