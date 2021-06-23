//
//  MBConfig.Feature+Repo.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/23.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

extension MBConfig.Feature {
    @_dynamicReplacement(for: remove(repo:))
    open func container_remove(repo: MBConfig.Repo) throws {
        self.config.currentFeature.removeContainer(repo.name)
        try self.remove(repo: repo)
    }

    open func removeContainer(_ name: String, tool: MBDependencyTool? = nil) {
        self.currentContainers.removeAll { container in
            if let t = tool, container.tool != t {
                return false
            }
            return container.isName(name)
        }
    }

    open func removeContainer(tool: MBDependencyTool) {
        self.currentContainers.removeAll { $0.tool == tool }
    }

    open func deactivateContainer(_ container: MBContainer) {
        self.currentContainers.removeAll(container)
    }

    open func activateContainer(_ container: MBContainer) {
        self.removeContainer(tool: container.tool)
        self.currentContainers.append(container)
    }
}
