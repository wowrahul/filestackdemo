//
//  CloudSourceDataSourceConsumer.swift
//  Filestack
//
//  Created by Ruben Nine on 11/17/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal protocol CloudSourceDataSourceConsumer {

    func dataSourceReceivedInitialResults(dataSource: CloudSourceDataSource)
}
