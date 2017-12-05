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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString(UpsideDownAdditions)
/// replace each char with a similar ringed one.
- (NSString *)ringed;

/// "Hello" -> "olleH"
- (NSString *)reverse;

/// replace each char with a similar upside down one.
- (NSString *)invert;

/// replace each char with a similar braille one.
- (NSString *)braille;

/// replace each char with a similar backwards one.
- (NSString *)backwards;

- (NSString *)smallCaps;

- (NSString *)verySmallCaps;


/// replace each char with a similar yinglish one.
- (NSString *)yinglish;

// These Math... methods all map A..Z,a..z to letter-like math glyphs.
// TODO: provide a single inverse function that maps them back to normal ascii
- (NSString *)mathSerifBold;
- (NSString *)mathSerifItalic;
- (NSString *)mathSerifBoldItalic;
- (NSString *)mathScriptItalic;
- (NSString *)mathScriptBoldItalic;
- (NSString *)mathGermanic;
- (NSString *)mathDouble;
- (NSString *)mathGermanicBold;
- (NSString *)mathSans;
- (NSString *)mathSansBold;
- (NSString *)mathSansItalic;
- (NSString *)mathSansBoldItalic;
- (NSString *)mathMono;

// These ...Caps methods all map A..Z,a..z to uppercase letter-like glyphs.
- (NSString *)boxedCaps;
- (NSString *)blackBoxedCaps;
- (NSString *)blackRingedCaps;
- (NSString *)dottedBoxedCaps;

// Array of combining strings.
- (NSString *)withCombining:(NSArray *)arrayOfCombiners;

/// -1 if not found.
- (int)indexOfCharacter:(unichar)c;
@end

NS_ASSUME_NONNULL_END
