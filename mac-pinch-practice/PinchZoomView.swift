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
  
  private(set) var minScale: CGFloat = 1.0 {
    didSet {
        delegate?.pinchZoomView(self, didChangeMinScale: minScale)
    }
  }

  private(set) var anchor: UnitPoint = .center {
      didSet {
          delegate?.pinchZoomView(self, didChangeAnchor: anchor)
      }
  }

  private(set) var offset: CGSize = .zero {
      didSet {
          delegate?.pinchZoomView(self, didChangeOffset: offset)
      }
  }

  private(set) var isPinching: Bool = false {
      didSet {
          delegate?.pinchZoomView(self, didChangePinching: isPinching)
      }
  }
  
  private var startLocation: CGPoint = .zero
  private var location: CGPoint = .zero
  private var numberOfTouches: Int = 0
  
  init() {
      super.init(frame: .zero)

      let pinchGesture = NSMagnificationGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
      addGestureRecognizer(pinchGesture)
  }
  
  required init?(coder: NSCoder) {
      fatalError()
  }
  
  @objc private func pinch(gesture: NSMagnificationGestureRecognizer) {
      switch gesture.state {
      case .began:
        isPinching = true
        startLocation = gesture.location(in: self)
        anchor = UnitPoint(x: startLocation.x / bounds.width, y: (bounds.height - startLocation.y) / bounds.height)
      case .changed:
        let magnification = gesture.magnification
        let scaleFactor = (magnification >= 0.0) ? (1.0 + magnification) : 1.0 / (1.0 - magnification)
        scale = scaleFactor
        location = gesture.location(in: self)
//        offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)
      case .ended, .cancelled, .failed:
        isPinching = false
        if scale <= minScale {
          scale = minScale
//          scaleFactor = 1.0
//          offset = .zero
        }
      default:
          break
      }
  }
}

protocol PinchZoomViewDelgate: AnyObject {
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeMinScale minScale: CGFloat)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
  func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

struct PinchZoom: NSViewRepresentable {
  
  typealias NSViewType = PinchZoomView
  
  @Binding var scale: CGFloat
  @Binding var minScale: CGFloat
  @Binding var anchor: UnitPoint
  @Binding var offset: CGSize
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
    var pinchZoom: PinchZoom

    init(_ pinchZoom: PinchZoom) {
        self.pinchZoom = pinchZoom
    }

    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool) {
        pinchZoom.isPinching = isPinching
    }
          
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat) {
      pinchZoom.scale = scale
    }

    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeMinScale minScale: CGFloat) {
      pinchZoom.minScale = minScale
    }
    
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
        pinchZoom.anchor = anchor
    }

    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize) {
        pinchZoom.offset = offset
    }
  }
}

struct PinchToZoom: ViewModifier {
  
  @State var scale: CGFloat = 1.0
  @State var minScale: CGFloat = 1.0
  @State var anchor: UnitPoint = .center
  @State var offset: CGSize = .zero
  @State var isPinching: Bool = false
  
  func body(content: Content) -> some View {
      content
        .scaleEffect(scale, anchor: anchor)
        .offset(offset)
        .animation(isPinching ? .none : .spring())
        .overlay(PinchZoom(scale: $scale, minScale: $minScale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
  }
}

extension View {
  func  pinchToZoom() -> some View {
    self.modifier(PinchToZoom())
  }
}
