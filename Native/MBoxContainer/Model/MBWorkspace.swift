//
//  MBWorkspace.swift
//  MBoxContainer
//
//  Created by 詹迟晶 on 2022/7/8.
//  Copyright © 2022 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspace
import MBoxDependencyManager

extension MBWorkspace {
    @_dynamicReplacement(for: workspaceIndex())
    public func container_workspaceIndex() -> [String: [(name: String, path: String)]] {
        var result = self.workspaceIndex()
        for tool in MBDependencyTool.allTools {
            let components = self.config.currentFeature.activatedContainers(for: tool)
            let name = tool.name.lowercased()
            var items = result[name] ?? []
            items << components.map { (name: $0.name, path: $0.path) }
            result[name] = items
        }
        return result
    }
}
