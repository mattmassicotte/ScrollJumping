# ScrollJumping
Sample app that demonstrates scroll jumping bug

To trigger the bug you need

- Text that is long enough to cause non-contiguous blocks **and** also wide enough to extend past the width for the NSTextView bounds
- Initiate a scroll event with a trackpad (just having one connected is not enough)

Pasting in the text from AppDelegate.swift three times is enough to trigger this.