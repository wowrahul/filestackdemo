//
//  ZipTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Takes the file or files that are passed into it and compresses them into a zip file.
 */
@objc(FSZipTransform) public class ZipTransform: Transform {

    /**
        Initializes a `ZipTransform` object.
     */
    public init() {

        super.init(name: "zip")
    }
}
