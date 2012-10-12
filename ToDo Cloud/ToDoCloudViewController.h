//
//  ToDoCloudViewController.h
//  ToDo Cloud
//
//  Created by Alexander Noguchi on 10/8/12.
//  Copyright (c) 2012 Alexander Noguchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoCloudLabel.h"

// TODO this shouldn't be hard coded
#define BUTTONS_HEIGHT 41

@interface ToDoCloudViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *taskInput;
@property (weak, nonatomic) IBOutlet UIView*taskField;
@property (weak, nonatomic) IBOutlet UILabel *deleteArea;
@property (weak, nonatomic) IBOutlet UILabel *completeArea;

@property (nonatomic) CGPoint visualCenter;
- (IBAction)addTask:(id)sender;
@end
