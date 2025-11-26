// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class TextSearcher {
  static RecordHitInfo? search(String target, String query) {
    var index = kmpSearch(target, query);
    if (index >= 0) {
      return RecordHitInfo(index, index + query.length);
    }
    return null;
  }

  // Function to compute the partial match table (pi) used by KMP
  static List<int> computePi(String pattern) {
    int m = pattern.length;
    List<int> pi = List.filled(m, 0);
    int k = 0;

    for (int j = 1; j < m; j++) {
      while (k > 0 && pattern[j] != pattern[k]) {
        // If mismatch occurs, fall back in the pi table
        k = pi[k - 1];
      }
      if (pattern[j] == pattern[k]) {
        // If characters match, increment the length of the prefix
        k++;
      }
      pi[j] = k; // pi[j] is now complete
    }

    return pi;
  }

  // KMP search function
  static int kmpSearch(String text, String pattern) {
    if (pattern.isEmpty) {
      return 0; // If pattern is empty, return 0 as it matches at the start
    }

    int m = pattern.length;
    int n = text.length;
    List<int> piTable = computePi(pattern); // Precompute the pi table
    int j = 0; // j is the index in pattern

    for (int i = 0; i < n; i++) {
      while (j > 0 && text[i] != pattern[j]) {
        // If mismatch occurs, use the pi table to skip characters
        j = piTable[j - 1];
      }
      if (text[i] == pattern[j]) {
        // If characters match, move to the next character in pattern
        j++;
      }
      if (j == m) {
        // If we have matched the whole pattern
        return i - m + 1; // Return the start index of the match
      }
    }

    return -1; // No match found
  }
}

class RecordHitInfo {
  int start;
  int end;

  RecordHitInfo(this.start, this.end);
}
