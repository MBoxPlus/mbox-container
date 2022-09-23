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
            guard repo.activatedContainers(for: tool).isEmpty else { continue }
            let activatedContainers = self.config.currentFeature.activatedContainers(for: tool)
            if workRepo.setting.container?.isAllowMultipleContainers(for: tool) != true,
                MBSetting.merged.container?.isAllowMultipleContainers(for: tool) != true {
                if !activatedContainers.isEmpty {
                    continue
                }
                if containers.count > 1 {
                    continue
                }
            }
            let toActivatedContainers = workRepo.setting.container?.defaultActivateContainers(containers, for: tool) ?? containers
            self.feature.activateContainers(toActivatedContainers)
        }
        self.config.save()
    }
}
