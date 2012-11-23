# 关于 ShareKit

[Sharekit](https://github.com/ShareKit/ShareKit) 在社区的驱动下迎来了 2.0 版本的重生（原开发者已不再维护）。

`develop` 分支是基于社区驱动的基础上支持开发，因此今后的更新都是在当前分支。

> 迁移有风险，操作需谨慎。

# 服务

## 可用服务

1. 新浪微博 (支持新浪微博官方 SSO OAuth 及 iOS 6 特性）
2. 微信（仅支持分享到朋友）
3. 网易微博
4. 腾讯微博
5. 豆瓣
6. 人人网
7. Plurk （融合自[polydice/ShareKit-Sharers](https://github.com/polydice/ShareKit-Sharers)）

## 计划服务

> 暂无（如果有需求可以提 Issue，但不一定会考虑 XD）


# 未来特性

当前的代码还是比较混乱，我不清楚社区是否会进行进行重构（以目前社区 Issue 看来是没有的），当国内服务整合差不多了，就开始对代码进行优化和重构，之后再进行更多特性的支持。下面是一个初步的计划。

* 优化代码（KISS）
* 多重分享
* 额外服务端支持


# 中文文档

> [Wiki](https://github.com/icyleaf/ShareKit/wiki) 计划中，尽情期待。


# 技术支持

仅用于持续改进项目代码沟通（疑难杂症概不回复）

 > 不要私下咨询我为什么服务已经开发，到现在还没有完成，是不是因为私心不愿意公布。
 > 线上的代码就是全部！

* Email: icyleaf.cn@gmail.com
* Twitter: @icyleaf
* 新浪微博: @icyleaf


ShareKit 2.0
============

In order to make it easier for new users to choose a canonical fork of ShareKit, the ShareKit community has decided to band together and take responsibility for collecting useful commits into what we're calling "ShareKit 2.0". It is now ready for you. It is the first officially stable version of ShareKit since February, with more frequent updates expected.

Highlights:

* new sharers (FourSquare, LinkedIn, VKontakte)
* Twitter on iOS 5 uses system dialogue
* many other improvements, mostly stability and memory issues
* optimized for adding as git submodule to your project for easy updating

You can follow the initial planning at https://github.com/ideashower/ShareKit/issues/283.

As ShareKit is now community driven, you are welcome to help, to judge new features, review pull requests etc.. There are many ways you can help, see [FAQ](https://github.com/ShareKit/ShareKit/wiki/FAQ)

Documentation
-------------

The latest documentation and installation instructions can be found on the [ShareKit Wiki](https://github.com/ShareKit/ShareKit/wiki).

!!! Updated new service creation guidelines for contributors are [here](https://github.com/ShareKit/ShareKit/wiki/New-service-creator's-guidelines) !!!