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

#import "AppDelegate.h"

#import "Mode.h"
#import "ModeModel.h"
#import "ModeTableViewController.h"
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate() <ModeTableViewDelegate, ViewControllerDelegate>
@property(nonatomic) ModeTableViewController *modeController;
@property(nonatomic) ViewController *viewController;
@property(nonatomic) UINavigationController *navMain;
@property(nonatomic) UISplitViewController *split;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
  ViewController *viewController = [[ViewController alloc] init];
  viewController.viewDelegate = self;
  _viewController = viewController;
  UINavigationController *navMain = [[UINavigationController alloc] initWithRootViewController:viewController];
  _navMain = navMain;

  CGRect bounds = [[UIScreen mainScreen] bounds];
  UIWindow *window = [[UIWindow alloc] initWithFrame:bounds];
  [self setWindow:window];

  BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
  if (isPad) {
    UINavigationController *navMode = [self constructNavMode];

    UISplitViewController *split = [[UISplitViewController alloc] init];
    _split = split;
    split.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    viewController.navigationItem.leftBarButtonItem = split.displayModeButtonItem;
    [split setViewControllers:@[navMode, navMain]];

    [window setRootViewController:split];
  } else {
    [window setRootViewController:navMain];
  }
  [window makeKeyAndVisible];
  [self initialUpdate];
  return YES;
}

- (void)tableViewControllerSelectedModeDidChange:(ModeTableViewController *)controller {
  [_viewController setMode:controller.selectedMode];
}

- (void)viewControllerModeDidChange:(ViewController *)controller {
  [_modeController setSelectedMode:controller.mode];
}

// In iPad split view compact mode, the left controller steals and pushes the root
// controller of the right nav controller.
// If we transition back to iPad split view compact mode the left nav controller needs a
// valid root controller.
- (void)viewController:(ViewController *)controller
              doneWith:(ModeTableViewController *)modeController {
  if (_modeController == modeController) {
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (isPad) {
      UINavigationController *navMode = [self constructNavMode];
      [_split setViewControllers:@[navMode, _navMain]];
    }
  }
}

- (UINavigationController *)constructNavMode {
  ModeTableViewController *modeController = [[ModeTableViewController alloc] init];
  _modeController = modeController;
  modeController.modeDelegate = self;
  Mode *mode = _viewController.mode;
  if (mode) {
    [_modeController setSelectedMode:mode];
  }
  return [[UINavigationController alloc] initWithRootViewController:modeController];
}

- (void)initialUpdate {
  NSString *modeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"mode"];
  ModeModel *modeModel = [ModeModel sharedInstance];
  Mode *mode = [modeModel modeForName:modeName];
  if (mode) {
    [_viewController setMode:mode];
    [_modeController setSelectedMode:mode];
  }
}

@end

NS_ASSUME_NONNULL_END
