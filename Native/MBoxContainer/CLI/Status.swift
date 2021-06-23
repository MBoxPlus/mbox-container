//
//  Add.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspace
import MBoxWorkspaceCore
import MBoxDependencyManager

extension MBCommander.Status {
    open class Containers: MBCommanderStatus {
        public static var supportedAPI: [MBCommander.Status.APIType] {
            return [.api]
        }

        public static var title: String {
            return "containers2"
        }

        public required init(feature: MBConfig.Feature) {
            self.feature = feature
        }

        public var feature: MBConfig.Feature

        public func APIData() throws -> Any? {
            return self.feature.allContainers.compactMap { container -> [String: Any]? in
                let dict = self.APIData(for: container)
                return dict.toCodableObject() as? [String: Any]
            }
        }

        dynamic
        public func APIData(for container: MBContainer) -> [String: Any] {
            var dict = container.dictionary
            dict["active"] = self.feature.isCurrentContainer(container)
            return dict
        }
    }

    // Forward compatible
    open class DeprecatedContainers: MBCommanderStatus {
        public static var supportedAPI: [MBCommander.Status.APIType] {
            return [.api, .none]
        }

        public static var title: String {
            return "containers"
        }

        public required init(feature: MBConfig.Feature) {
            self.feature = feature
        }

        public var feature: MBConfig.Feature

        public func textRows() throws -> [Row]? {
            return feature.allContainerDescriptions
        }
        
        public func APIData() throws -> Any? {
            var containerGroups = [String: [MBContainer]]()
            self.feature.allContainers.forEach { container in
                if containerGroups[container.repoName] != nil {
                    containerGroups[container.repoName]! << container
                } else {
                    containerGroups[container.repoName] = [container]
                }
            }
            return containerGroups.map { (repoName, containers) -> [String: Any] in
                var dict = [String: Any]()
                dict["name"] = repoName
                dict["tools"] = containers.map { ["name": $0.tool.description, "active": self.feature.isCurrentContainer($0)] }
                return dict
            }
        }
    }

    @_dynamicReplacement(for: allSections)
    public class var container_allSections: [MBCommanderStatus.Type] {
        var result = self.allSections
        result << Containers.self
        result << DeprecatedContainers.self
        return result
    }
}
