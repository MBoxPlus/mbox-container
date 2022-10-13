//
//  MBWorkRepo.Container.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/8/10.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxDependencyManager

var kMBWorkRepoContainersKey: UInt8 = 0
extension MBWorkRepo {
    dynamic
    public func fetchContainers() -> [Container] {
        return []
    }

    public var containers: [Container] {
        return associatedObject(base: self, key: &kMBWorkRepoContainersKey) {
            return self.fetchContainers()
        }
    }

    func resetContainerCache() {
        resetAssociatedObject(base: self, key: &kMBWorkRepoContainersKey)
    }

    public func containers(for tool: MBDependencyTool) -> [Container] {
        return self.containers.filter {
            $0.tool == tool
        }
    }

    public func container(named: String, for tool: MBDependencyTool) -> Container? {
        return self.containers.first {
            $0.tool == tool && $0.isName(named)
        }
    }
}
