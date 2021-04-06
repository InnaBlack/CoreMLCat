//
//  File.swift
//  CoreMLCat
//
//  Created by  inna on 04/04/2021.
//

import UIKit
import SwiftUI
import Vision
import CoreML

public struct CatDetectionView: UIViewRepresentable {
    
    @ObservedObject var viewModel: CatDetectionViewModel = .init()
    @Binding var imageCat: UIImage?
    
    public func makeUIView(context: UIViewRepresentableContext<CatDetectionView>) -> UIView {
        viewModel.currentImg = imageCat ?? UIImage()
        viewModel.detectScene()
        return viewModel.resultView
    }
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<CatDetectionView>) {
        
    }
}


final class CatDetectionViewModel: ObservableObject {
    
    // Trained Models
    
    private let objectModel: CatImageClassifier_3 = CatImageClassifier_3()
    
    var currentImg: UIImage = .init()
    
    // UI
    private var currentImageView: UIImageView = .init(frame: .init(x: 0, y: 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2))
    private var answerLabel: UILabel = .init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    var resultView: UIView = .init(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    
    
    init() {
        setupUI()
    }
    
    private func setupUI() {
       
        resultView.addSubview(answerLabel)
        resultView.addSubview(currentImageView)
    }
    
    // MARK: - Methods
    func detectScene() {
        
        guard let ciImage = CIImage(image: currentImg) else {
            fatalError("Not able to convert UIImage to CIImage")
        }
        currentImageView.image = currentImg
        answerLabel.text = "Detecting image..."
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: objectModel.model) else {
            fatalError("Can't load Inception ML model")
        }
        
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                fatalError("Unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            DispatchQueue.main.async { [weak self] in
                self?.answerLabel.text = "\(Int(topResult.confidence * 100))% it's \(topResult.identifier)"
            }
        }
        
        // Run the Core ML model classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}
