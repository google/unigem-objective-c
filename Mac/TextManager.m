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

#import "TextManager.h"

#import "Mode.h"
#import "ModeSelector.h"

@interface TextManager() <ModeSelectorDelegate, NSTextFieldDelegate>
@property(weak) IBOutlet NSTextField *normalText;
@property(weak) IBOutlet NSTextField *transformedText;
@property(weak) IBOutlet NSTextField *label;
@property(weak) IBOutlet ModeSelector *modeSelector;
@end

@implementation TextManager

- (void)controlTextDidChange:(NSNotification *)notification {
  [self transformText:[notification object]];
}

- (void)transformText:(id)sender {
  if (sender == _normalText) {
    [self update];
  }
}

- (void)modeSelectorDidChange:(ModeSelector *)modeSelector {
  [self update];
}

- (void)update {
  Mode *mode = _modeSelector.selectedMode;
  if (mode) {
    NSString *s = [NSString stringWithFormat:@"Transformed using “%@” Here:",
        [mode transform:mode.name]];
    [_label setStringValue:s];
    [_transformedText setStringValue:[mode transform:[_normalText stringValue]]];
  }
}

@end
