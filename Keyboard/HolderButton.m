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

#import "HolderButton.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HolderButton

- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state {
  [super setTitle:title forState:state];
  if (nil == _initialTitle) {
    [self setInitialTitle:title];
  }
}

@end

NS_ASSUME_NONNULL_END
