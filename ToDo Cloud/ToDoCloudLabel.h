//
//  ToDoCloudLabel.h
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/9/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//
#import "utils.h"

#define MINIMUM_FONT_SIZE   20
#define MAXIMUM_FONT_SIZE   40
#define FONT_RESIZE_FACTOR  12.5

typedef struct {
    int    x;
    int    y;
} Direction;

NSString* NSStringFromDirection(Direction d);
BOOL directionIsZero(Direction d);
Direction inverseDirection(Direction d);

@interface ToDoCloudLabel : UILabel <NSCoding, UIActionSheetDelegate>{
    CGPoint currentPoint;
    CGRect previousPosition;
}
@property (nonatomic, assign) CGPoint visualCenter;
@property (nonatomic, assign) Direction lastPushedDirection;
@property (nonatomic, assign) CGRect anchor;

- (id)initWithText: (NSString *)text center:(CGPoint)center;
- (id)initAtCenterWithText: (NSString *)text withVisualCenter:(CGPoint)visualCenter;

- (Direction)pushDirectionFor:(ToDoCloudLabel *)pushedLabel;

- (CGPoint)getShift;
- (CGRect)anchoredFrame;

- (BOOL)moveToCenter;
- (BOOL)boundedShiftBy:(CGPoint)shiftFactor;
- (BOOL)boundedMoveToNewCenter:(CGPoint)newPoint;
- (void)snapToAnchor;
- (void)updateFontSize;

- (BOOL)isInBounceZone;
- (void)bounceAwayFromBottom;

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
