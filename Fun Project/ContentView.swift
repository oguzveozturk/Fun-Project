//
//  ContentView.swift
//  Fun Project
//
//  Created by Oğuz Öztürk on 10.12.2021.
//

import SwiftUI
import NukeUI
import Combine

final class ViewModel:ObservableObject {
    let urls = (0...49).map { "https://picsum.photos/id/\($0)/" }
    
    @Published var isThumbsLoaded = false
    
    var images = [UIImage]() {
        didSet {
            if images.count == urls.count {
                isThumbsLoaded = true
            }
        }
    }
    
    init() {
        loadThumbs()
    }
    
    private func loadThumbs() {
        urls.forEach { url in
            ImagePipeline.shared.loadImage(
                with: url+"4/7") { [weak self] response in
                    switch response {
                    case .failure:
                        print("fail")
                        self?.images.append(UIImage())
                    case let .success(imageResponse):
                        print("success")
                        self?.images.append(imageResponse.image)
                    }
                }
        }
    }
    
}

struct ContentView: View {
    
@StateObject var viewModel = ViewModel()
    
    var body: some View {
       VStack {
            ScrollView {
                LazyVStack(spacing:1) {
                    if viewModel.isThumbsLoaded {
                        ForEach(Array(viewModel.urls.enumerated()), id:\.offset) { i,url in
                            
                            LazyImage(source: url+"800/1400") { state in
                                if let image = state.image {
                                    image
                                } else {
                                    Image(ImageContainer(image: viewModel.images[i])).blur(radius: 10)
                                }
                            }
                            .frame(height: 400)
                        }
                    } else {
                        ProgressView()
                            .frame(width: 100, height: 100)
                            .offset(y:100)
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
