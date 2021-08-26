//
//  MBCommander.swift
//  MBoxContainer
//
//  Created by Whirlwind on 2021/6/21.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBCommander {
    open func validateMultipleContainers(for tool: MBDependencyTool) throws {
        let containers = self.config.currentFeature.activatedContainers(for: tool)
        if containers.count > 1,
           MBSetting.merged.container?.allowMultipleContainers(for: tool) != true {
            var tips = ["There are multiple activated containers for \(tool):"]
            for container in containers {
                tips.append("  - \(container.name)")
            }
            tips.append("")
            tips.append("You could activate a container by the command:")
            tips.append("      \(containers.map { "mbox container use \($0.name)" }.joined(separator: "\n  or: "))")
            throw UserError(tips.joined(separator: "\n"))
        }
    }
}
