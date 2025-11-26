<p align="center">
  <h1 align="center"> <code>open_filex</code> </h1>
</p>

本项目基于 [open_filex](https://pub.dev/packages/open_filex) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
...

dependencies:
  open_filex:
    git:
      url: https://gitcode.com/openharmony-sig/fluttertpc_open_filex.git
...
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [example](./example/lib/main.dart)。

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过:

1. Flutter: 3.7.12-ohos-1.1.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name | Description | Type     | Input                                       | Output       | ohos Support |
| ---- | ----------- | -------- | ------------------------------------------- | ------------ | ------------ |
| open | 打开文件    | function | String filePath,{String? type, String? uti} | Future<File> | yes          |

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name     | Description          | Type   | Input | Output | ohos Support |
| -------- | -------------------- | ------ | ----- | ------ | ------------ |
| fileName | 要打开的文件路径     | String | /     | /      | yes          |
| type     | 文件的 MIME 类型提示 | String | /     | /      | yes          |
| uti      | 统一类型标识符       | String | /     | /      | yes          |

## 5. 遗留问题

## 6. 其他

## 7. 开源协议

本项目基于 [The BSD-3-Clause License](./LICENSE)，请自由地享受和参与开源。
