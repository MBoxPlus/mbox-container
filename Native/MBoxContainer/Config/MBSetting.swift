//
//  MBSetting.swift
//  MBoxContainer
//
//  Created by Whirlwind on 2021/6/20.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBSetting {

    public class Container: MBCodableObject {
        @Codable
        public var allowMultipleContainers: [String]?

        public func isAllowMultipleContainers(for tool: MBDependencyTool) -> Bool {
            guard let tools = self.allowMultipleContainers?.map({ $0.lowercased() }) else { return false }
            return tools.contains(tool.name.lowercased())
        }

        public func allowMultipleContainers(for tool: MBDependencyTool) {
            if isAllowMultipleContainers(for: tool) { return }
            var tools = self.allowMultipleContainers ?? []
            tools.append(tool.name)
            self.allowMultipleContainers = tools
        }

        public func allowMultipleContainers(for tools: [MBDependencyTool]) {
            for tool in tools {
                self.allowMultipleContainers(for: tool)
            }
        }

        public func disallowMultipleContainers(for tool: MBDependencyTool) {
            if !isAllowMultipleContainers(for: tool) { return }
            var tools = self.allowMultipleContainers ?? []
            tools.removeAll {
                $0.lowercased() == tool.name.lowercased()
            }
            self.allowMultipleContainers = tools
        }

        public func disallowMultipleContainers(for tools: [MBDependencyTool]) {
            for tool in tools {
                self.disallowMultipleContainers(for: tool)
            }
        }
    }

    public var container: Container? {
        set {
            self.dictionary["container"] = newValue
        }
        get {
            return self.value(forPath: "container")
        }
    }
}
