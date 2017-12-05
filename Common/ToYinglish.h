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
// Yinglish is a command line tool that takes a file argument and writes output to standard out.
// It turns English Localizable.strings into mock Hebrew, for debugging left to right layout issues.
// I wrote it as a tool for me: I know the Hebrew alphabet, but can't read Hebrew.
// By analogy with Yiddish which is German spelled with Hebrew letters.
// by David Phillip Oster 5/18/2014 Open source under Apache 2 license

// Given a UTF-8 English string, which may include escapes like \n and and \t
// return a "Yinglish", i.e. English spelled with Hebrew characters strings.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

const char *ToYinglish(const char *inString);

NSString *ToYinglishS(NSString *inS);

// These unicode characters are supposed to force a layout order
extern const unichar ltrPrefixChar;
extern const unichar rtlPrefixChar;

// The above unicode characters as NSStrings.
extern NSString * const ltrPrefixS;
extern NSString * const rtlPrefixS;

NS_ASSUME_NONNULL_END
