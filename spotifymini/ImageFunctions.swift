//
//  ImageFunctions.swift
//  spotifymini
//
//  Created by admin on 4/6/23.
//  Author: Zappy code
//  gist.github.com/zappycode/688ecbe0d851c324dadd4caf9ba5f39f

import Foundation
import Cocoa

func resizeImage(image:NSImage, maxSize:NSSize) -> NSImage {
        var ratio:Float = 0.0
        let imageWidth = Float(image.size.width)
        let imageHeight = Float(image.size.height)
        let maxWidth = Float(maxSize.width)
        let maxHeight = Float(maxSize.height)
        
        // Get ratio (landscape or portrait)
        if (imageWidth > imageHeight) {
            // Landscape
            ratio = maxWidth / imageWidth;
        }
        else {
            // Portrait
            ratio = maxHeight / imageHeight;
        }
        
        // Calculate new size based on the ratio
        let newWidth = imageWidth * ratio
        let newHeight = imageHeight * ratio
        
        // Create a new NSSize object with the newly calculated size
        let newSize:NSSize = NSSize(width: Int(newWidth), height: Int(newHeight))
        
        // Cast the NSImage to a CGImage
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        
        // Create NSImage from the CGImage using the new size
        let imageWithNewSize = NSImage(cgImage: imageRef!, size: newSize)
        
        // Return the new image
        return imageWithNewSize
    }
