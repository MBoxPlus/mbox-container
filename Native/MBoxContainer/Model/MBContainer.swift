//
//  MBContainer.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/12/16.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

public class MBContainer: MBCodableObject {
    @Codable
    public var name: String

    @Codable
    public var repoName: String

    @Codable
    public var tool: MBDependencyTool

    public weak var feature: MBConfig.Feature?

    public lazy var repo: MBConfig.Repo? = {
        return feature?.findRepo(name: repoName, searchPackageName: false).first
    }()

    public convenience init(name: String, repoName: String? = nil, tool: MBDependencyTool) {
        self.init()
        self.repoName = repoName ?? name
        self.name = name
        self.tool = tool
    }

    public func isName(_ name: String) -> Bool {
        let name = String(name.split(separator: "/").first!)
        if let repo = repo, repo.isName(name) {
            return true
        }
        return self.name.lowercased() == name.lowercased()
    }

    dynamic
    public func description(feature: MBConfig.Feature) -> Row {
        let row = Row()
        if feature.isCurrentContainer(name: name) {
            row.selected = true
            row.columns << name.ANSI(.yellow)
            row.columns << tool.description.ANSI(.yellow)
        } else {
            row.columns << name
            row.columns << tool.description
        }

        return row
    }

    public override var description: String {
        return "Container `\(self.name)` (\(self.tool))"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if super.isEqual(object) { return true }
        guard let other = object as? MBContainer else { return false }
        return self.repoName == other.repoName && self.name == other.name && self.tool == other.tool
    }
}
