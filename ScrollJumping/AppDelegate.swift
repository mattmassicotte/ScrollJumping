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
        ruleThickness = 100.0
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: NSViewController {
    private let scrollView: NSScrollView

    init() {
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

        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 600.0, height: 300.0))

        textView.insertionPointColor = NSColor.textColor
        textView.textColor = NSColor.textColor
        textView.layoutManager?.allowsNonContiguousLayout = true
        textView.isEditable = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false

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
