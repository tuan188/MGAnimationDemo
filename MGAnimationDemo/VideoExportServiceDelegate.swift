//
//  VideoExportServiceDelegate.swift
//  MP_ARNewYearIOS
//
//  Created by Tuan Truong on 7/22/15.
//  Copyright (c) 2015 com.framgia. All rights reserved.
//

import Foundation

protocol VideoExportServiceDelegate: class {
    func videoExportServiceExportSuccess()
    func videoExportServiceExportFailedWithError(error: NSError)
    func videoExportServiceExportProgress(progress: Float)
}