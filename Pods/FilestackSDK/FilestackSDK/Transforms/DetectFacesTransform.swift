//
//  DetectFacesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Detects the faces contained inside an image.
 */
@objc(FSDetectFacesTransform) public class DetectFacesTransform: Transform {

    /**
     Initializes a `ResizeTransform` object.
     */
    public init() {

        super.init(name: "detect_faces")
    }

    /**
        Adds the `minSize` option.

        - Parameter value: This parameter is used to weed out objects that most likely
        are not faces. Valid range: `0.01...10000`
     */
    @discardableResult public func minSize(_ value: Float) -> Self {

        options.append((key: "minsize", value: value))

        return self
    }

    /**
        Adds the `maxSize` option.

        - Parameter value: This parameter is used to weed out objects that most likely
        are not faces. Valid range: `0.01...10000`
     */
    @discardableResult public func maxSize(_ value: Float) -> Self {

        options.append((key: "maxsize", value: value))

        return self
    }

    /**
        Adds the `color` option.

        - Parameter value: Will change the color of the "face object" boxes and text.
     */
    @discardableResult public func color(_ value: UIColor) -> Self {

        options.append((key: "color", value: value.hexString))

        return self
    }

    /**
     Adds the `export` option.

     - Parameter value: If true, it will export all face objects to a JSON object.
     */
    @discardableResult public func export(_ value: Bool) -> Self {

        options.append((key: "export", value: value))

        return self
    }
}
