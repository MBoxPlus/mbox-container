//
//  Add.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspace
import MBoxDependencyManager

extension MBCommander.Status {
    public static let containerSectionName = "containers"
    open class Containers: MBCommanderStatus {
        public static var supportedAPI: [MBCommander.Status.APIType] {
            return [.api]
        }

        public static var title: String {
            return "containers2"
        }

        public required init() {
            fatalError()
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
        public func APIData(for container: MBWorkRepo.Container) -> [String: Any] {
            var dict: [String: Any] = container.dictionary
            dict["active"] = self.feature.isActivated(container: container)
            if let repoName = container.repo?.name {
                dict["repo_name"] = repoName
            }
            return dict
        }
    }

    // Forward compatible
    open class DeprecatedContainers: MBCommanderStatus {
        public static var supportedAPI: [MBCommander.Status.APIType] {
            return [.api, .none]
        }

        public static var title: String {
            return Status.containerSectionName
        }

        public required init() {
            fatalError()
        }

        public required init(feature: MBConfig.Feature) {
            self.feature = feature
        }

        public var feature: MBConfig.Feature

        public func textRows() throws -> [Row]? {
            return feature.allContainerDescriptions
        }
        
        public func APIData() throws -> Any? {
            var containerGroups = [String: [MBWorkRepo.Container]]()
            self.feature.allContainers.forEach { container in
                guard let repoName = container.repo?.name else { return }
                if containerGroups[repoName] != nil {
                    containerGroups[repoName]! << container
                } else {
                    containerGroups[repoName] = [container]
                }
            }
            return containerGroups.map { (repoName, containers) -> [String: Any] in
                var dict = [String: Any]()
                dict["name"] = repoName
                dict["tools"] = containers.map { ["name": $0.tool.description, "active": self.feature.isActivated(container: $0)] }
                return dict
            }
        }
    }

    @_dynamicReplacement(for: allSections)
    public class var container_allSections: [MBCommanderEnv.Type] {
        var result = self.allSections
        result << Containers.self
        result << DeprecatedContainers.self
        return result
    }
}
