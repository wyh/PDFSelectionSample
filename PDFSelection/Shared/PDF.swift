//
//  PDF.swift
//  PDFSelection
//
//  Created by 科研猫 on 2021/12/24.
//


import Foundation
import SwiftUI

import PDFKit
import os.log

typealias MakingSelectionClosure = (_ pdfView: IvyPDFView) -> Void
typealias SelectionClosure = (_ pdfView: IvyPDFView, _ selection: PDFSelection) -> Void

typealias PDFDocumentChangeClosure = (_ pdfView: IvyPDFView, _ document: PDFDocument) -> Void



class IvyPDFView: PDFView {
    var startPoint = CGPoint()

    weak var usePDFViewDelegate: IvyPDFViewDelegate?

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        super.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)

        if gestureRecognizer.name == "IvyPan" && otherGestureRecognizer.classForCoder == UILongPressGestureRecognizer.self {
            return false
        }
        
        if gestureRecognizer.name == "IvyPan" && otherGestureRecognizer.classForCoder == DragGesture.self {
            return false
        }

        if (otherGestureRecognizer.name == "IvyPan" || gestureRecognizer.name == "IvyPan") {
            return true
        }

        return false
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                     shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {


         // Do not begin the pan until the swipe fails.
         if gestureRecognizer.name == "IvyDoubleTap" && otherGestureRecognizer.name == "IvyPan" {
             return false
         }

         if gestureRecognizer.classForCoder == UILongPressGestureRecognizer.self && otherGestureRecognizer.name == "IvyPan" {
             return false
         }

         if gestureRecognizer.name == "IvyDoubleTap" {
             return true
         }

         return false
     }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        let panRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.panSelection))
        panRecognizer.name = "IvyPan"
        panRecognizer.minimumPressDuration = 0.3
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector((self.doubleTap)))
               doubleTap.name = "IvyDoubleTap"
               doubleTap.numberOfTapsRequired = 2
               doubleTap.delegate = self

        self.addGestureRecognizer(doubleTap)

    }

    @objc func panSelection(recognizer: UIPanGestureRecognizer) {
        guard recognizer.view != nil else {
            return
        }

        let piece = recognizer.view!
        if recognizer.state == .began {
            // Save the view's original position.
            // And move left a little as finger can press wider area
            let point = recognizer.location(in: piece)
            startPoint = CGPoint(x: point.x - 15, y: point.y)

        }
        // Update the position for the .began, .changed, and .ended states
        if recognizer.state != .cancelled {
            // Add the X and Y translation to the view's original position.
            // let newPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
            let newPoint = recognizer.location(in: piece)
            // piece.center = newCenter
            if let page = self.currentPage {
                let originalPoint = self.convert(startPoint, to: page)
                let endPoint = self.convert(newPoint, to: page)
                currentSelection = self.currentPage?.selection(from: originalPoint, to: endPoint)
                usePDFViewDelegate?.makingSelection(pdfView: self)
            }
        }
        if (recognizer.state == .ended) {
            if let currentSelection = self.currentSelection {
                // show Selection Bar when finger lifted
                self.usePDFViewDelegate?.usePDFView(self, selectionMade: currentSelection)
            }
        }

    }
    
    @objc func doubleTap(recognizer: UIPanGestureRecognizer) {
            guard let piece = recognizer.view else {
                return
            }

            let tapPoint = recognizer.location(in: piece)

            if let page = self.currentPage {

                let location = self.convert(tapPoint, to: page)
                let selection = self.currentPage?.selectionForWord(at: location)
                self.setCurrentSelection(selection, animate: false)
                usePDFViewDelegate?.makingSelection(pdfView: self)
                
            }

        }
}

protocol IvyPDFViewDelegate: AnyObject {
    func usePDFView(_ pdfView: IvyPDFView, selectionMade selection: PDFSelection)
    func makingSelection(pdfView: IvyPDFView)
}

struct PDFKitView: UIViewRepresentable {
    @State var data: Data

    @State private var pdfView: IvyPDFView

    var onSelection: MakingSelectionClosure
    var setSelection: SelectionClosure


    init(
         data: Data,
         onSelection: @escaping MakingSelectionClosure,
         setSelection: @escaping SelectionClosure
    ) {
        self.onSelection = onSelection
        self.setSelection = setSelection
        _pdfView = State(initialValue: IvyPDFView())
        _data = State(initialValue: data)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(representedView: self)
    }

    func makeUIView(context: Context) -> some UIView {
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        pdfView.enableDataDetectors = true
        pdfView.usePDFViewDelegate = context.coordinator

        return pdfView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

extension PDFKitView {
    class Coordinator: NSObject, IvyPDFViewDelegate, PDFViewDelegate {

        var representedView: PDFKitView

        init(representedView: PDFKitView) {
            self.representedView = representedView
        }

        func usePDFView(_ pdfView: IvyPDFView, selectionMade: PDFSelection) {
            representedView.setSelection(pdfView, selectionMade)
        }

        func makingSelection(pdfView: IvyPDFView) {
            representedView.onSelection(pdfView)
        }

    }
}

extension PDFView {
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}


extension UIView {
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
