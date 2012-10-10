//
//  ToDoCloudViewController.h
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/8/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUIAnimatableLabel.h"

// TODO this shouldn't be hard coded
#define BUTTONS_HEIGHT 41

@interface ToDoCloudViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *taskInput;
@property (weak, nonatomic) IBOutlet UIView *taskField;
@property (nonatomic) CGPoint visualCenter;
- (IBAction)addTask:(id)sender;
@end
