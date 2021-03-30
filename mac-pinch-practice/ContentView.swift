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
    GeometryReader { geometry in
      ScrollView([.horizontal, .vertical], showsIndicators: false) {
        Image("Bird")
          .resizable()
          .pinchToZoom(width: $width, height: $height)
      }.scaledToFill() 
    }
  }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(width: 640, height: 480)
    }
}
