/*
  Copyright 2017 Google Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

#import "ViewController.h"

#import "Mode.h"
#import "ModeModel.h"
#import "ModeTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController () <UINavigationControllerDelegate, UITextFieldDelegate>
@property(nonatomic) UILabel *inputLabel;
@property(nonatomic) UITextField *inputText;
@property(nonatomic) UILabel *outputLabel;
@property(nonatomic) UITextField *outputText;
@property(nonatomic) UIButton *showModesButton;
@property(nonatomic) CGFloat keyboardHeight;
@property(nonatomic) UILabel *keyboardReminder;
@property(nonatomic) UIScrollView *scrollView;
@property(nonatomic) NSString *outputLabelText;
@property(nonatomic, nullable) ModeTableViewController *modeTable;
@property(nonatomic) CGSize boundsSize;
@end

@implementation ViewController

- (instancetype)initWithNibName:(nullable NSString *)nibName bundle:(nullable NSBundle *)nibBundle {
  self = [super initWithNibName:nibName bundle:nibBundle];
  if (self) {
    _mode = [Mode identity];
  }
  return self;
}

- (void)loadView {
  [self setTitle:@"Unicode Gems"];
  CGRect frame = [[UIScreen mainScreen] bounds];
  UIScrollView *view = [[UIScrollView alloc] initWithFrame:frame];
  [view setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1]];
  _scrollView = view;

  _inputLabel = [[UILabel alloc] initWithFrame:frame];
  [_inputLabel setText:@"Type Here:"];
  [view addSubview:_inputLabel];

  _keyboardReminder = [[UILabel alloc] initWithFrame:frame];
  [_keyboardReminder setNumberOfLines:0];
  NSString *reminder = @"This app has a custom keyboard to use in other apps.\n\n"
  "Turn it on in Setting > General > Keyboard > Keyboards > Add New Keyboard\n\n"
  "You might need to restart your phone the very first time to get it to show up.";
  [_keyboardReminder setText:reminder];
  [_keyboardReminder setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
  [view addSubview:_keyboardReminder];

  _inputText = [[UITextField alloc] initWithFrame:frame];
  [_inputText setClearButtonMode:UITextFieldViewModeAlways];
  [_inputText setBorderStyle:UITextBorderStyleLine];
  [_inputText setDelegate:self];
  [view addSubview:_inputText];

  _outputLabel = [[UILabel alloc] initWithFrame:frame];
  if (nil == _outputLabelText) {
    _outputLabelText = [@"Copy from Here: " stringByAppendingString:[_mode transform:_mode.name]];
  }
  [_outputLabel setText:_outputLabelText];
  [view addSubview:_outputLabel];
  [_outputLabel setUserInteractionEnabled:YES];
  UITapGestureRecognizer *tapper =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showModes)];
  [_outputLabel addGestureRecognizer:tapper];

  _outputText = [[UITextField alloc] initWithFrame:frame];
  [_outputText setBorderStyle:UITextBorderStyleLine];
  [_outputText setDelegate:self];
  [view addSubview:_outputText];

  _showModesButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_showModesButton setTitle:@"Select Mode" forState:UIControlStateNormal];
  [_showModesButton addTarget:self action:@selector(showModes) forControlEvents:UIControlEventTouchUpInside];
  [view addSubview:_showModesButton];
  
  [self setView:view];

  // In iOS 10 and up these will be removed automatically by dealloc.
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(keyboardWillShow:)
             name:UIKeyboardWillShowNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(keyboardWillHide:)
             name:UIKeyboardWillHideNotification
           object:nil];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  if (nil == self.view.superview) {
    return;
  }
  CGRect bounds = [self.view bounds];
  bounds.size.height = self.view.superview.bounds.size.height - _keyboardHeight;
  if (!CGSizeEqualToSize(_boundsSize, bounds.size)) {
    _boundsSize = bounds.size;
    CGRect remainder = bounds;
    remainder.size.height = 1000; // i.e. tall enough for all our content.
    remainder.origin = CGPointZero;
    CGRect inputRect;
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 8, 8, 8);
    // The root view of this view controller is a scrollview, and inside a UINavigatinController,
    // automatically adjusts for the nav bar and stats bar.

    CGRectDivide(remainder, &inputRect, &remainder, 50, CGRectMinYEdge);
    inputRect = UIEdgeInsetsInsetRect(inputRect, insets);
    [_inputLabel setFrame:inputRect];

    CGRectDivide(remainder, &inputRect, &remainder, 50, CGRectMinYEdge);
    inputRect = UIEdgeInsetsInsetRect(inputRect, insets);
    [_inputText setFrame:inputRect];
    CGRect outputRect;

    CGRectDivide(remainder, &outputRect, &remainder, 50, CGRectMinYEdge);
    outputRect = UIEdgeInsetsInsetRect(outputRect, insets);
    [_outputLabel setFrame:outputRect];

    CGRectDivide(remainder, &outputRect, &remainder, 50, CGRectMinYEdge);
    outputRect = UIEdgeInsetsInsetRect(outputRect, insets);
    [_outputText setFrame:outputRect];

    CGRect buttonRect;
    CGRectDivide(remainder, &buttonRect, &remainder, 50, CGRectMinYEdge);
    buttonRect = UIEdgeInsetsInsetRect(buttonRect, insets);
    [_showModesButton setFrame:buttonRect];

    CGRect reminderRect;
    CGRectDivide(remainder, &reminderRect, &remainder, 150, CGRectMinYEdge);

    UIScrollView *scrollView = _scrollView;
    CGSize contentSize = bounds.size;
    contentSize.height = reminderRect.size.height + reminderRect.origin.y;
    
    reminderRect = UIEdgeInsetsInsetRect(reminderRect, insets);
    [_keyboardReminder setFrame:reminderRect];
    
    [scrollView setContentSize:contentSize];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self updateForKeyboard];
  [self updateTraits];
  [_inputText becomeFirstResponder];
}

- (void)updateTraits {
  BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
  if (isPad) {
    isPad = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular;
  }
  [_showModesButton setHidden:isPad];
}

- (void)makeSpaceForKeyboard:(float)height
                       curve:(UIViewAnimationCurve)curve
                    duration:(NSTimeInterval)duration {
  _keyboardHeight = height;
  [UIView beginAnimations:@"keyboardChange" context:NULL];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    [self updateForKeyboard];
  [UIView commitAnimations];
}

- (void)updateForKeyboard {
  CGRect r = [[self.view superview] bounds];
  r.size.height -= _keyboardHeight;
  [self.view setFrame:r];
}


- (void)keyboardWillShow:(NSNotification *)note {
  if (0 == _keyboardHeight) {
    NSDictionary *info = [note userInfo];
    NSTimeInterval duration = [[info
        objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[info
        objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    // in screen coordinates.
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    [self makeSpaceForKeyboard:keyboardHeight
                         curve:curve
                      duration:duration];
  }
}

- (void)keyboardWillHide:(NSNotification *)note {
  if (0 != _keyboardHeight) {
    NSDictionary *info = [note userInfo];
    NSTimeInterval duration = [[info
      objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [[info
      objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    UIViewAnimationCurve curve = UIViewAnimationCurveEaseInOut;
    if (options & UIViewAnimationOptionCurveEaseOut) {
      curve = UIViewAnimationCurveEaseOut;
    } else if (options & UIViewAnimationOptionCurveEaseIn) {
      curve = UIViewAnimationCurveEaseIn;
    } else if (options & UIViewAnimationOptionCurveLinear) {
      curve = UIViewAnimationCurveLinear;
    }
    [self makeSpaceForKeyboard:0
                         curve:curve
                      duration:duration];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setMode:(Mode *)mode {
  if (![_mode isEqual:mode]) {
    _mode = mode;
    [self updateMode];
    NSString *name = mode.name;
    if (name) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:name forKey:@"mode"];
      [defaults synchronize];
    }
    [_viewDelegate viewControllerModeDidChange:self];
  }
}

- (void)updateMode {
  _outputLabelText = [@"Copy from Here: " stringByAppendingString:[_mode transform:_mode.name]];
  [_outputLabel setText:_outputLabelText];
  _outputText.text = [_mode transform:_inputText.text];
}

- (void)showModes {
  if (![_showModesButton isHidden]) {
    _modeTable = _viewDelegate.modeController;
    if (nil == _modeTable) {
      _modeTable = [[ModeTableViewController alloc] init];
    }
    [_modeTable setSelectedMode:_mode];
    [self setTitle:@"Done"];
    [self.navigationController setDelegate:self];
    [self.navigationController pushViewController:_modeTable animated:YES];
  }
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if (self == viewController) {
    [self setTitle:@"Unicode Gems"];
  }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if (self == viewController && nil != _modeTable) {
    [self setMode:[_modeTable selectedMode]];
    [_viewDelegate viewController:self doneWith:_modeTable];
    _modeTable = nil;
  }
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (textField == _inputText) {
    NSString *s = [textField text];
    s = [s stringByReplacingCharactersInRange:range withString:string];
     _outputText.text = [_mode transform:s];
    return YES;
  }
  return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
  _outputText.text = @"";
  return YES;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
  [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
  BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
  if (isPad) {
    [self updateTraits];
  }
}


@end

NS_ASSUME_NONNULL_END
