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

        public func allowMultipleContainers(for tool: MBDependencyTool) -> Bool {
            guard let tools = self.allowMultipleContainers?.map({ $0.lowercased() }) else { return false }
            return tools.contains(tool.name.lowercased())
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
