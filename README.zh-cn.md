# Container for MBox

其他语言：[English](./README.md)

MBox 的 Container 插件，用来拓展 Workspace 下，区分哪些仓库是 Container，哪些仓库是普通组件。如果存在多个主容器，用户能够通过选择主容器的方式来切换开发对象。

该插件只是一个抽象，不提供具体容器分析逻辑，具体容器分析需要额外的依赖管理工具。目前已有的容器插件有：

1. [MBoxRuby](https://github.com/mboxplus/mbox-ruby.git) 提供 Bundler 容器支持
1. [MBoxCocoapods](https://github.com/mboxplus/mbox-cocoapods.git) 提供 CocoaPods 容器支持

## Command

```
Usage:

    $ mbox container

      Manage Container

Commands:

    + disuse    Deactive container in current feature
    + list      List available containers in current feature
    + use       Active container in current feature

```

#### mbox container use NAME

激活指定的 `NAME` 容器为主容器

#### mbox container disuse NAME

取消指定的 `NAME` 容器

#### mbox container list

列出所有的容器和激活状态

## Dependency

该插件只能在 Workspace 下生效

依赖的 MBox 组件：

1. MBoxCore
1. MBoxGit
1. MBoxWorkspace
1. MBoxDependencyManager

## 激活插件

该插件无需手动激活，一般由具体的依赖管理工具引入

## Contributing
Please reference the section [Contributing](https://github.com/MBoxPlus/mbox#contributing)

## License
MBox is available under [GNU General Public License v2.0 or later](./LICENSE).
