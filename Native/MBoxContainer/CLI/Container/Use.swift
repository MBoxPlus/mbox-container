//
//  Use.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBCommander.Container {
    open class Use: Switch {

        open class override var description: String? {
            return "Active container in current feature"
        }

        dynamic
        open override func validate() throws {
            try super.validate()

            let dict = Dictionary(grouping: self.containers, by: \.tool)
            for (tool, containers) in dict {
                if containers.count <= 1 { continue }
                if let config = MBSetting.merged.container,
                   config.isAllowMultipleContainers(for: tool) {
                    continue
                }
                throw UserError("[\(tool)] Could not activate containers \(containers.map{ "`\($0.name)`"}.joined(separator: "、")). Activate multi-containers for \(tool) is disallowed.")
            }
        }

        dynamic
        open override func switchContainers(_ containers: [MBWorkRepo.Container]) throws {
            try super.switchContainers(containers)
            UI.log(info: "Use containers:") {
                let currentFeature = self.config.currentFeature
                currentFeature.activateContainers(containers)
            }
        }
    }
}
