//
//  Add.swift
//  MBoxContainer
//
//  Created by 詹迟晶 on 2021/9/9.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore

extension MBCommander.Add {
    @_dynamicReplacement(for: shouldFetchCommitToCheckout())
    public func container_shouldFetchCommitToCheckout() -> Bool {
        if !self.shouldFetchCommitToCheckout() {
            return false
        }
        return self.config.currentFeature.activatedContainers.count > 0
    }

    @_dynamicReplacement(for: run())
    public func container_run() throws {
        try self.run()
        guard let repo = self.addedRepo,
              repo.containers == nil,
              let workRepo = repo.workRepository else {
            return
        }
        for (tool, containers) in Dictionary(grouping: workRepo.containers, by: \.tool) {
            let activatedContainers = self.config.currentFeature.activatedContainers(for: tool)
            guard repo.activatedContainers(for: tool).isEmpty else { continue }
            if MBSetting.merged.container?.isAllowMultipleContainers(for: tool) != true {
                if !activatedContainers.isEmpty {
                    continue
                }
                if containers.count > 1 {
                    continue
                }
            }
            self.feature.activateContainers(containers)
        }
        self.config.save()
    }
}
