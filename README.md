# iOS Rotating MoviePlayerController


## What it does

A MPMoviePlayerController subclass that forces the movie to rotate while on fullscreen.

Imagine your app only works in portrait orientation but you still want your videos to be able to rotate while on fullscreen. You could present it modally, but if you want to add it to a view, like an article detail, you have a problem.

This subclass solves it for iOS 5, and as you can see by the example it works fine in iOS 6 too (because the difference in Apple's implementation).

## How does it work

In iOS 5 it forces the rotation of the device, except for upside down (it would be easy to add). It does this by applying a transform to the keywindow and changing the status bar orientation, all of it correctly animated.
