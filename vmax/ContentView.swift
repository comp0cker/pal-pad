//
//  PageViewController.swift
//  vmax
//
//  Created by Jared Grimes on 12/20/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var showSearch = false
    
    func searchOn() {
        showSearch = true
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Button(action: searchOn) {
                    Text("Add card")
                }
                NavigationLink (destination: SearchView(showSearch: $showSearch), isActive: $showSearch) {
                    EmptyView()
                }
            }.navigationBarTitle("vmax")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
