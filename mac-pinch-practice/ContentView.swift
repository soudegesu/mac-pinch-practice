//
//  ContentView.swift
//  mac-pinch-practice
//
//  Created by soudegesu on 2021/03/25.
//

import SwiftUI

struct ContentView: View {
  
  var body: some View {
    Group {
      ScrollView(.horizontal ) {
        Image("Bird")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .pinchToZoom()
      }.frame(width: 1280, height: 800)
    }
  }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
