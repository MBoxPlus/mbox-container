//
//  Import.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/31.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspace
import MBoxDependencyManager

//extension MBCommander.Feature.Import {
//    @_dynamicReplacement(for: switchFeature(args:))
//    open func container_switchFeature(args: [String]) throws {
//        try self.switchFeature(args: args)
//        let currentFeature = self.config.currentFeature
//
//        guard currentFeature.dictionary["current_container_repos"] == nil else {
//            return
//        }
//
//        var usingContainers = [String]()
//        MBDependencyTool.allTools.forEach { (tool) in
////            guard currentFeature.currentContainerRepos(platformTool: tool).count == 0 else {
////                return
////            }
////            if let repo = currentFeature.containerRepos(platformTool: tool).first {
////                usingContainers.append(repo.name)
////            }
//        }
//
//        if usingContainers.count > 0 {
//            usingContainers.forEach { currentFeature.addCurrentContainer(name: $0) }
//            self.config.save()
//        }
//    }
//}
