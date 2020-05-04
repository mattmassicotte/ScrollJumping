//
//  AppDelegate.swift
//  ScrollJumping
//
//  Created by Matt Massicotte on 2020-05-03.
//  Copyright © 2020 My Company. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.contentViewController = ViewController()
    }
}

class MyRulerView: NSRulerView {
    override init(scrollView: NSScrollView?, orientation: NSRulerView.Orientation) {
        super.init(scrollView: scrollView, orientation: orientation)

        // to make the problem more obvious
        ruleThickness = 77.0
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class JumpingBugWorkaroundScrollView: NSScrollView {
    private var lastPosition: CGFloat = 0.0

    private var textView: NSTextView? {
        return documentView as? NSTextView
    }

    private var hasTextViewWithNonContiguousLayout: Bool {
        return textView?.layoutManager?.hasNonContiguousLayout == true
    }

    private var workaroundChecksNeeded: Bool {
        guard hasVerticalRuler else {
            return false
        }

        guard hasTextViewWithNonContiguousLayout else {
            return false
        }

        return true
    }

    // determined emperically and is possibly OS-version dependent. Unsure
    // why the leading and trailing sides are the same
    private var magicLeadingMarginDistance: CGFloat {
        return 5.0
    }

    private var magicTrailingMarginDistance: CGFloat {
        return 5.0
    }

    private var rulerSideTripLength: CGFloat {
        let thickness = verticalRulerView?.requiredThickness ?? 0.0

        return thickness - magicLeadingMarginDistance
    }

    private func shouldFilterScrollPoint(_ newPoint: NSPoint) -> Bool {
        guard workaroundChecksNeeded else {
            return false
        }

        let newPos = newPoint.x
        let lastPos = lastPosition

        // this is -1.0 and not 0.0 to give a little slack so that
        // the scroll appears smooth on the trailing side
        if lastPos < -1.0 && newPos == 0.0 {
            return true
        }

        // this is a weird behavior on the trailing side
        if lastPos == 0.0 && newPos == -magicTrailingMarginDistance {
            return true
        }

        // handles the leading side cases
        if lastPos < -rulerSideTripLength && newPos == -rulerSideTripLength {
            return true
        }

        return false
    }

    override func scroll(_ clipView: NSClipView, to point: NSPoint) {
        if shouldFilterScrollPoint(point) {
            let filteredPoint = NSPoint(x: lastPosition, y: point.y)

            super.scroll(clipView, to: filteredPoint)

            return
        }

        lastPosition = point.x

        super.scroll(clipView, to: point)
    }
}

class ViewController: NSViewController {
    private let scrollView: NSScrollView

    init() {
//        self.scrollView = JumpingBugWorkaroundScrollView(frame: NSRect(x: 0, y: 0, width: 600.0, height: 300.0))
        self.scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 600.0, height: 300.0))

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.verticalRulerView = MyRulerView(scrollView: scrollView, orientation: .verticalRuler)
        scrollView.rulersVisible = true

        // basic textview configuration
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 600.0, height: 300.0))

        textView.insertionPointColor = NSColor.textColor
        textView.textColor = NSColor.textColor
        textView.layoutManager?.allowsNonContiguousLayout = true
        textView.isEditable = true

        // ensure text is not wrapped
        let max = CGFloat.greatestFiniteMagnitude
        textView.textContainer?.size = CGSize(width: max, height: max)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.textContainer?.widthTracksTextView = false

        scrollView.documentView = textView

        textView.layoutManager?.delegate = self

        self.view = scrollView
    }
}

extension ViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        // once this happens, problem will disappear
        Swift.print("did complete layout")
    }
}
