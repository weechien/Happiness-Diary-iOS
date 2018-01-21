import UIKit

class AssetExtractor {
    
    static func createLocalUrl(forImageNamed name: String) -> URL? {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).webp")
        let path = url.path
        
        guard fileManager.fileExists(atPath: path) else {
            guard
                let image = UIImage(named: name),
                let data = UIImagePNGRepresentation(image)
                else { return nil }
            
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
            return url
        }
        
        return url
    }
    
}
