import SwiftUI

struct RemoteImage: View {
    let url: String
    @State private var image: NSImage?
    @State private var isLoading = true
    @State private var debugInfo: String = ""
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Group {
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .padding(4)
                } else if isLoading {
                    ProgressView()
                } else {
                    VStack {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        
                        if !debugInfo.isEmpty {
                            Text(debugInfo)
                                .font(.caption2)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        // First try loading from bundle
        if let bundleImage = loadFromBundle() {
            self.image = bundleImage
            self.isLoading = false
            return
        }
        
        // If bundle loading fails, try loading from URL
        loadFromURL()
    }
    
    private func loadFromBundle() -> NSImage? {
        // Try to find the image in the main bundle
        if let bundlePath = Bundle.main.path(forResource: url, ofType: nil) {
            return NSImage(contentsOfFile: bundlePath)
        }
        
        // If not found directly, try looking in the PokemonImages directory
        let filename = (url as NSString).lastPathComponent
        if let imagePath = Bundle.main.path(forResource: (filename as NSString).deletingPathExtension,
                                          ofType: (filename as NSString).pathExtension,
                                          inDirectory: "PokemonImages") {
            return NSImage(contentsOfFile: imagePath)
        }
        
        debugInfo = "Image not found in bundle: \(url)"
        return nil
    }
    
    private func loadFromURL() {
        guard url.hasPrefix("http") else {
            debugInfo = "Not a valid URL and not found in bundle: \(url)"
            isLoading = false
            return
        }
        
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let imageURL = URL(string: encodedUrl) else {
            debugInfo = "Could not create valid URL from: \(url)"
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    debugInfo = "Network error: \(error.localizedDescription)"
                    isLoading = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    debugInfo = "Invalid response type"
                    isLoading = false
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    debugInfo = "HTTP Error: \(httpResponse.statusCode)"
                    isLoading = false
                    return
                }
                
                guard let data = data else {
                    debugInfo = "No data received"
                    isLoading = false
                    return
                }
                
                guard let loadedImage = NSImage(data: data) else {
                    debugInfo = "Could not create image from data (size: \(data.count) bytes)"
                    isLoading = false
                    return
                }
                
                self.image = loadedImage
                self.isLoading = false
            }
        }
        task.resume()
    }
} 