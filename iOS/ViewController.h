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

#import <UIKit/UIKit.h>

#import "ModeTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class Mode;
@class ModeTableViewController;
@protocol ViewControllerDelegate;

@interface ViewController : UIViewController
@property(nonatomic, weak) id<ViewControllerDelegate> viewDelegate;
@property(nonatomic) Mode *mode;
@end


@protocol ViewControllerDelegate <NSObject>
@property(nonatomic, readonly, nullable) ModeTableViewController *modeController;
- (void)viewControllerModeDidChange:(ViewController *)controller;
- (void)viewController:(ViewController *)controller
              doneWith:(ModeTableViewController *)modeController;
@end

NS_ASSUME_NONNULL_END
