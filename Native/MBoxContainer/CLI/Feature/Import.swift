//
//  Import.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/31.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspace
import MBoxDependencyManager

extension MBCommander.Feature.Import {
    @_dynamicReplacement(for: buildFeature(fromString:))
    public func container_buildFeature(fromString string: String) throws -> MBConfig.Feature {
        let feature = try self.buildFeature(fromString: string)
        self.config.migrateContainers(feature: feature)
        return feature
    }
}
