import Foundation
import UIKit
import AsyncDisplayKit

open class ASImageNode: ASDisplayNode {
    public var image: UIImage? {
        didSet {
            if self.isNodeLoaded {
                if let image = self.image {
                    let capInsets = image.capInsets
                    if capInsets.left.isZero && capInsets.top.isZero && capInsets.right.isZero && capInsets.bottom.isZero {
                        self.contentsScale = image.scale
                        self.contents = image.cgImage
                    } else {
                        ASDisplayNodeSetResizableContents(self.layer, image)
                    }
                } else {
                    self.contents = nil
                }
                if self.image?.size != oldValue?.size {
                    self.invalidateCalculatedLayout()
                }
            }
        }
    }

    public var displayWithoutProcessing: Bool = true
    
    private static let imageCache = NSCache<NSURL, UIImage>()
    
    private static var diskCacheDirectory: URL = {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let diskCacheDirectory = cacheDirectory.appendingPathComponent("ASImageNodeDiskCache")
        
        if !FileManager.default.fileExists(atPath: diskCacheDirectory.path) {
            try? FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return diskCacheDirectory
    }()
    
    override public init() {
        super.init()
    }
    
    override open func didLoad() {
        super.didLoad()
        
        if let image = self.image {
            let capInsets = image.capInsets
            if capInsets.left.isZero && capInsets.top.isZero {
                self.contentsScale = image.scale
                self.contents = image.cgImage
            } else {
                ASDisplayNodeSetResizableContents(self.layer, image)
            }
        }
    }
    
    override public func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        return self.image?.size ?? CGSize()
    }

    // New method to set image with URL, placeholder, options, and completion
    public func setImage(with url: URL?,
                         placeholderImage: UIImage? = nil,
                         options: ASImageNodeOptions = [],
                         completion: ((UIImage?, Error?) -> Void)? = nil) {
        // Set placeholder image
        self.image = placeholderImage
        
        guard let url = url else {
            completion?(nil, NSError(domain: "ASImageNodeErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let urlKey = url as NSURL
        
        // Check memory cache
        if let cachedImage = ASImageNode.imageCache.object(forKey: urlKey) {
            self.image = cachedImage
            completion?(cachedImage, nil)
            return
        }
        
        // Check disk cache
        let diskCacheURL = ASImageNode.diskCacheDirectory.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: diskCacheURL.path),
           let cachedImage = UIImage(contentsOfFile: diskCacheURL.path) {
            ASImageNode.imageCache.setObject(cachedImage, forKey: urlKey)
            self.image = cachedImage
            completion?(cachedImage, nil)
            return
        }
        
        // Download image if not cached
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
                return
            }
            
            if let mimeType = response?.mimeType {
                print("MIME type: \(mimeType)")
            }
            
            if let downloadedImage = UIImage(data: data) {
                // Cache the image in memory
                ASImageNode.imageCache.setObject(downloadedImage, forKey: urlKey)
                
                // Cache the image on disk
                try? data.write(to: diskCacheURL)
                
                DispatchQueue.main.async {
                    self.image = downloadedImage
                    completion?(downloadedImage, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion?(nil, NSError(domain: "ASImageNodeErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create image from data"]))
                }
            }
        }
        task.resume()
    }
}

// Options for ASImageNode, you can extend this as needed
public struct ASImageNodeOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let refreshCached = ASImageNodeOptions(rawValue: 1 << 0)
    public static let continueInBackground = ASImageNodeOptions(rawValue: 1 << 1)
    public static let lowPriority = ASImageNodeOptions(rawValue: 1 << 2)
}
