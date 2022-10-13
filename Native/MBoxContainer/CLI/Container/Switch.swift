//
//  Switch.swift
//  MBoxContainer
//
//  Created by Whirlwind on 2021/1/26.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBCommander.Container {
    open class Switch: Container {

        open class override var description: String? {
            return "Switch container in current feature"
        }

        open class override var arguments: [Argument] {
            var arguments = super.arguments
            arguments << Argument("name", description: "Container Name", required: true, plural: true)
            return arguments
        }

        dynamic
        open override class var options: [Option] {
            var options = super.options
            options << Option("tool", description: "Dependency Tool", values: MBDependencyTool.allTools.map(\.name))
            return options
        }

        open override class var flags: [Flag] {
            var flags = super.flags
            flags << Flag("all", description: "Select All Containers")
            return flags
        }

        open var names: [String] = []
        open var tools: [MBDependencyTool]?
        open var allContainers: Bool = false

        open var containers: [MBWorkRepo.Container] = []

        dynamic
        open override func setup() throws {
            self.allContainers = self.shiftFlag("all")
            if let toolNames: [String] = self.shiftOptions("tool") {
                self.tools = try toolNames.map { try MBDependencyTool.tool(for: $0) }
            }
            try super.setup()
            self.names = self.shiftArguments("name")
            self.showStatusAtFinish = [Status.containerSectionName]
            self.requireSetupEnvironment = true
        }

        dynamic
        open override func validate() throws {
            let currentFeature = self.config.currentFeature

            self.containers = currentFeature.allContainers
            if !self.allContainers {
                if self.names.isEmpty {
                    throw ArgumentError.missingArgument("name")
                }
                self.containers = self.containers.filter { container in
                    return self.names.contains { container.isName($0) }
                }
            }

            if let tools = self.tools {
                self.containers = self.containers.filter { tools.contains($0.tool) }
            }

            if self.containers.isEmpty {
                throw UserError("Could not find the containers.")
            }

            try super.validate()
        }

        dynamic
        open override func run() throws {
            try super.run()

            try self.switchContainers(self.containers)
//                let platformRepos = currentFeature.containerRepos(platformTool:platformTool)
//                let needClearWorkspaceEnv = (platformRepos.count > 1)
//                if (needClearWorkspaceEnv) {
//                    try backupContainerFiles(platformTool: platformTool)
//                    try clearWorkspaceEnv(platformTool: platformTool)
//                }
//
//                try switchContainer(name: name, platformTool: platformTool)
//                if (needClearWorkspaceEnv) {
//                    try restoreContainerFiles(platformTool: platformTool)
//                }
//
//                let currentContainers = currentFeature.currentContainers(platformTool:platformTool)
//                if currentContainers.count > 1 {
//                    UI.log(warn: "Platform `\(platformTool)` have multiple containers", summary: false)
//                }
            self.config.save()
        }

        dynamic
        open func switchContainers(_ containers: [MBWorkRepo.Container]) throws {

        }

        private func clearWorkspaceEnv(platformTool: MBDependencyTool) throws {
            let feature = self.config.currentFeature
            try feature.clearWorkspaceEnv(platformTool: platformTool)
        }

        private func backupContainerFiles(platformTool: MBDependencyTool) throws {
            let feature = self.config.currentFeature
            try feature.backupContainerFiles(tool: platformTool)
        }

        private func restoreContainerFiles(platformTool: MBDependencyTool) throws {
            let feature = self.config.currentFeature
            try feature.restoreContainerFiles(tool: platformTool)
        }

    }
}

