//
//  ContentView.swift
//  mac-pinch-practice
//
//  Created by soudegesu on 2021/03/25.
//

import SwiftUI

struct ContentView: View {
  
  @State var width: CGFloat
  @State var height: CGFloat
  
  var body: some View {
    Group {
      ScrollView([.horizontal, .vertical], showsIndicators: false) {
        Image("Bird")
          .resizable()
          .pinchToZoom(width: width, height: height)
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(width: 640, height: 480)
    }
}
