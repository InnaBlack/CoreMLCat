//
//  ContentView.swift
//  CoreMLCat
//
//  Created by  inna on 04/04/2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
                    VStack {
                        NavigationLink(destination:NavigationLazyView(CatDetectionView(imageCat: $inputImage))) {
                            Text("Проверить")
                        }
                    }.sheet(isPresented: $showingImagePicker, onDismiss: {
                       
                    }) {
                        ImagePicker(image: self.$inputImage)
                    }.onAppear(perform: { self.showingImagePicker = true})
                }
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        Image(uiImage: inputImage)
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
