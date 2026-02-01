//
//  ImageConverter.swift
//  MIS
//
//  Created by Emircan Duman on 21.01.25.
//

import UIKit
import ImageIO
import UniformTypeIdentifiers

enum ImageConverter {
    static func convertToJPG(data: Data, compressionQuality: CGFloat = 0.8) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = UIImage(data: data) else {
            return nil
        }
        
        let originalMetadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        
        guard let jpegData = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        guard let metadata = originalMetadata else {
            return jpegData
        }
        
        guard let source = CGImageSourceCreateWithData(jpegData as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return jpegData
        }
        
        let destinationData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            destinationData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return jpegData
        }
        
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        
        CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
        CGImageDestinationSetProperties(destination, options as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else {
            return jpegData
        }
        
        return destinationData as Data
    }

    static func convertToJPGWithFilename(data: Data, filename: String, compressionQuality: CGFloat = 0.8) -> (data: Data, filename: String)? {
        guard let jpgData = convertToJPG(data: data, compressionQuality: compressionQuality) else {
            return nil
        }

        let nameWithoutExtension = (filename as NSString).deletingPathExtension

        return (jpgData, nameWithoutExtension)
    }
}
