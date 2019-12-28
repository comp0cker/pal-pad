//
//  UX.swift
//  Pal Pad
//
//  Created by Jared Grimes on 12/26/19.
//  Copyright © 2019 Jared Grimes. All rights reserved.
//

import SwiftUI

let swipeLRTolerance = 50

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
