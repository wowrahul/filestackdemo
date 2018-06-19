//
//  URL+mimeType.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import MobileCoreServices


extension URL {

    internal func mimeType() -> String? {

        let ext = pathExtension as CFString

        guard let utiRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, nil) else {
            return nil
        }

        let uti = utiRef.takeUnretainedValue()
        utiRef.release()

        guard let mimeTypeRef = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType) else {
            return nil
        }

        let mimeType = mimeTypeRef.takeUnretainedValue()
        mimeTypeRef.release()

        return mimeType as String
    }
}
