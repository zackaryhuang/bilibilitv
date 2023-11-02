//
//  Tools.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/24.
//

import CoreImage.CIFilterBuiltins
import Foundation
import UIKit

class Tools {
    static func generateQRCode(from url: String) -> UIImage? {
        let data = Data(url.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            return createUIImageFromCIImage(image: outputImage, size: 1024)
        }
        return nil
    }

    private static func createUIImageFromCIImage(image: CIImage, size: CGFloat) -> UIImage {
        let extent = image.extent.integral
        let scale = min(size / extent.width, size / extent.height)

        /// Create bitmap
        let width = size_t(extent.width * scale)
        let height = size_t(extent.height * scale)
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmap = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 1)!

        ///
        let context = CIContext()
        let bitmapImage = context.createCGImage(image, from: extent)
        bitmap.interpolationQuality = .none
        bitmap.scaleBy(x: scale, y: scale)
        bitmap.draw(bitmapImage!, in: extent)

        let scaledImage = bitmap.makeImage()
        return UIImage(cgImage: scaledImage!)
    }
}
