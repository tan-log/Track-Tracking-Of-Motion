//
//  ContentView.swift
//  MyMapkit
//
//  Created by tan on 2021/11/26.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        MapView()
    }
}

//@Binding init
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CoordinatePath())
    }
}
