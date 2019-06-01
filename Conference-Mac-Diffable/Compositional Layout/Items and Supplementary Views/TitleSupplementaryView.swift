/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A generic header view that has an NSTextField
*/

import Cocoa

class TitleSupplementaryView: NSView {
    @IBOutlet weak var label: NSTextField!
    static let reuseIdentifier = NSUserInterfaceItemIdentifier("title-supplementary-reuse-identifier")
}
