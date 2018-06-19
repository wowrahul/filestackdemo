//
//  PolaroidTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Applies a Polaroid border effect to the image.
 */
@objc(FSPolaroidTransform) public class PolaroidTransform: Transform {

    /**
        Initializes a `PolaroidTransform` object.
     */
    public init() {

        super.init(name: "polaroid")
    }

    /**
        Adds the `color` option.

        - Parameter value: Sets the Polaroid frame color.
     */
    @discardableResult public func color(_ value: UIColor) -> Self {

        options.append((key: "color", value: value.hexString))

        return self
    }

    /**
        Adds the `rotate` option.

        - Parameter value: The degree by which to rotate the image clockwise. Valid range: `0...359`
     */
    @discardableResult public func rotate(_ value: Int) -> Self {

        options.append((key: "rotate", value: value))

        return self
    }

    /**
        Adds the `background` option.

        - Parameter value: Sets the background color to display behind the Polaroid if
            it has been rotated at all.
     */
    @discardableResult public func background(_ value: UIColor) -> Self {

        options.append((key: "background", value: value.hexString))
        
        return self
    }
}
