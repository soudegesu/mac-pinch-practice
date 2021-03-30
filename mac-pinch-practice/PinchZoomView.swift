//
//  PinchZoomView.swift
//  mac-pinch-practice
//
//  Created by soudegesu on 2021/03/26.
//

import SwiftUI
import AppKit

class PinchZoomView: NSView {
  
  weak var delegate: PinchZoomViewDelgate?
  
  private(set) var scale: CGFloat = 1.0 {
      didSet {
        delegate?.pinchZoomView(self, didChangeScale: scale)
      }
  }
    
  private(set) var anchor: UnitPoint = .center {
      didSet {
          delegate?.pinchZoomView(self, didChangeAnchor: anchor)
      }
  }

  private(set) var isPinching: Bool = false {
      didSet {
          delegate?.pinchZoomView(self, didChangePinching: isPinching)
      }
  }
    
  private var startLocation: CGPoint = .zero
  private var location: CGPoint = .zero
  private var previousMagnification: CGFloat = 0.0
  private let minScale: CGFloat = 1.0

  init() {
      super.init(frame: .zero)

      let pinchGesture = NSMagnificationGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
      addGestureRecognizer(pinchGesture)
  }
  
  required init?(coder: NSCoder) {
      fatalError()
  }
  
  @objc private func pinch(gesture: NSMagnificationGestureRecognizer) {
      let currentMagnification = previousMagnification + gesture.magnification
    
      switch gesture.state {
      case .began:
        isPinching = true
        startLocation = location
        anchor = UnitPoint(x: startLocation.x / bounds.width, y: (bounds.height - startLocation.y)  / bounds.height)
      case .changed:
        let scaleFactor = (currentMagnification >= 0.0) ? (1.0 + currentMagnification) : 1.0 / (1.0 - currentMagnification)
        location = gesture.location(in: self)
        scale = scaleFactor
      case .ended, .cancelled, .failed:
        isPinching = false
        if scale <= minScale {
          scale = minScale
          previousMagnification = 0.0
        } else {
          previousMagnification = currentMagnification
        }
      default:
          break
      }
  }
}

protocol PinchZoomViewDelgate: AnyObject {
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
}

struct PinchZoom: NSViewRepresentable {
  
  typealias NSViewType = PinchZoomView
  
  @Binding var scale: CGFloat
  @Binding var anchor: UnitPoint
  @Binding var isPinching: Bool
  
  func makeNSView(context: Context) -> PinchZoomView {
    let view = PinchZoomView()
    view.delegate = context.coordinator
    return view
  }
  
  func updateNSView(_ nsView: PinchZoomView, context: Context) {
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, PinchZoomViewDelgate {
    private var pinchZoom: PinchZoom

    init(_ pinchZoom: PinchZoom) {
        self.pinchZoom = pinchZoom
    }

    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
        pinchZoom.isPinching = isPinching
    }
          
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
      pinchZoom.scale = scale
    }
    
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
        pinchZoom.anchor = anchor
    }
  }
}

struct PinchToZoomModifier: ViewModifier {
  
  @State var scale: CGFloat = 1.0
  @State var anchor: UnitPoint = .center
  @State var isPinching: Bool = false
  var width: CGFloat = 0.0
  var height: CGFloat = 0.0
  
  func body(content: Content) -> some View {
    content
      .aspectRatio(contentMode: .fit)
      .frame(width: width * scale, height: height * scale, alignment: .center)
//      .animation(isPinching ? .none : .spring())
      .overlay(PinchZoom(scale: $scale, anchor: $anchor, isPinching: $isPinching))
  }
}

extension View {
  func pinchToZoom(width: CGFloat, height: CGFloat) -> some View {
    self.modifier(PinchToZoomModifier(width: width, height: height))
  }
}
