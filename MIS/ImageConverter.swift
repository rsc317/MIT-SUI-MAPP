//
//  ImageConverter.swift
//  MIS
//
//  Created by Emircan Duman on 21.01.25.
//

import UIKit

enum ImageConverter {
    static func convertToJPG(data: Data, compressionQuality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        return image.jpegData(compressionQuality: compressionQuality)
    }

    static func convertToJPGWithFilename(data: Data, filename: String, compressionQuality: CGFloat = 0.8) -> (data: Data, filename: String)? {
        guard let jpgData = convertToJPG(data: data, compressionQuality: compressionQuality) else {
            return nil
        }

        let nameWithoutExtension = (filename as NSString).deletingPathExtension

        return (jpgData, nameWithoutExtension)
    }
}
