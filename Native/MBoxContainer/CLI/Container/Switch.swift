//
//  Switch.swift
//  MBoxContainer
//
//  Created by 詹迟晶 on 2021/1/26.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

extension MBCommander.Container {
    open class Switch: Container {

        open class override var description: String? {
            return "Switch container in current feature"
        }

        open class override var arguments: [Argument] {
            var arguments = super.arguments
            arguments << Argument("name", description: "Container Name", required: true)
            return arguments
        }

        dynamic
        open override class var options: [Option] {
            var options = super.options
            options << Option("tool", description: "Dependency Tool", values: MBDependencyTool.allTools.map(\.name))
            return options
        }

        open var name: String = ""
        open var tools: [MBDependencyTool]?

        dynamic
        open override func setup() throws {
            if let toolNames: [String] = self.shiftOptions("tool") {
                self.tools = try toolNames.map { try MBDependencyTool.tool(for: $0) }
            }
            try super.setup()
            self.name = try self.shiftArgument("name")
            self.showStatusAtFinish = true
            self.requireSetupEnvironment = true
        }

        dynamic
        open override func validate() throws {
            let currentFeature = self.config.currentFeature

            // check whether `name` is container repo
            if let tools = self.tools {
                for tool in tools{
                    let container = currentFeature.container(named: name, tool: tool)
                    if container == nil {
                        throw UserError("`\(name)` is NOT a \(tool) container")
                    }
                }
            } else {
                let container = currentFeature.container(named: name)
                if container.isEmpty {
                    throw UserError("`\(name)` is NOT a container")
                }
            }

            try super.validate()
        }

        dynamic
        open override func run() throws {
            try super.run()

            let currentFeature = self.config.currentFeature

            let tools = self.tools ?? MBDependencyTool.allTools
            for tool in tools {
                guard let container = currentFeature.container(named: self.name, tool: tool) else {
                    UI.log(info: "No found container `\(self.name)` for \(tool)")
                    continue
                }
                try self.switchContainer(container)
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
            }
            self.config.save()
        }

        dynamic
        open func switchContainer(_ container: MBContainer) throws {

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

