# Apple Watch Activity Custom Progress Indicator

The Apple Watch shipped with a captivating activity tracker.  The center piece is a really cool spiral animation scheme showing the amount of activity during the day.  This image is also shown on the matching iPhone Activity App.  I have always wanted to see what it would take to implement this myself.  The examples that I see typically use a custom drawRect override, but I always wanted to see what it would take to do with CAShapeLayers.

Implementing a 0-100% control is straight forward when using CAShapeLayer.  But how do you implement a progress indicator that support progress values greater then 100%?  This How To discusses a solution that I came up with along with it’s potential limitations.

This is the source code for a demo application that is decribed in the blog article [ How To: Custom iOS Activity Tracker View Using CALayers ](http://www.spazstik-software.com/blog/article/how-to-custom-ios-activity-tracker-view-using-calayers).

*Rodger Higgins is the founder of [Spazstik Software, LLC](http://www.spazstik-software.com).  He has created [StackCalc, The Visual Touch Calculator](http://www.spazstik-software.com/products/stackcalc) and [SPZTracker](http://www.spazstik-software.com/products/spztracker.ios).*
