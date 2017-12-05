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

#import "SelectorCell.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SelectorCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _textLabel = [[UILabel alloc] initWithFrame:frame];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:_textLabel];
    _detailLabel = [[UILabel alloc] initWithFrame:frame];
    [_detailLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:_detailLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGRect bounds = [self.contentView bounds];
  CGRect textR, detailR;
  UIEdgeInsets insets = UIEdgeInsetsMake(0, 4, 0, 4);
  CGRectDivide(bounds, &detailR, &textR, 12, CGRectMaxYEdge);
  detailR = UIEdgeInsetsInsetRect(detailR, insets);
  textR = UIEdgeInsetsInsetRect(textR, insets);
  [_textLabel setFrame:textR];
  [_textLabel setFont:[UIFont systemFontOfSize:MIN(20, textR.size.height - 2)]];
  [_detailLabel setFrame:detailR];
  [_detailLabel setFont:[UIFont systemFontOfSize:detailR.size.height - 2]];
}

@end

NS_ASSUME_NONNULL_END

