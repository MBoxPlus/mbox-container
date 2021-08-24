//
//  Use.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBCommander.Container {
    open class List: Container {

        open class override var description: String? {
            return "List available containers in current feature"
        }

        open override func setup() throws {
            try super.setup()
            UI.verbose = true
        }

        open override func run() throws {
            try super.run()

            try UI.section("List available containers:") {
                try output()
            }
        }

        open func output() throws {
            let currentFeature = self.config.currentFeature
            let infos = formatTable(currentFeature.allContainerDescriptions)
            infos.forEach { (info) in
                UI.log(info: info)
            }

            MBDependencyTool.allTools.forEach { (platformTool) in
                let activatedContainers = currentFeature.activatedContainers(for: platformTool)
                if activatedContainers.count > 1 {
                    UI.log(warn: "Platform `\(platformTool)` have multiple containers", summary: false)
                }
            }
        }
    }
}
