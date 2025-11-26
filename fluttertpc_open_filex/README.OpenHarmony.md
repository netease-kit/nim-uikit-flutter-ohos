<p align="center">
  <h1 align="center"> <code>open_filex</code> </h1>
</p>

This project is based on [open_filex](https://pub.dev/packages/open_filex).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

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

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [ohos/example](./example/lib/main.dart).

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.7.12-ohos-1.1.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;
2. Flutter: 3.22.1-ohos-1.0.3; SDK: 5.0.0(12); IDE: DevEco Studio: 5.1.0.828; ROM: 5.1.0.130 SP8;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

| Name | Description    | Type     | Input                                       | Output       | ohos Support |
| ---- | -------------- | -------- | ------------------------------------------- | ------------ | ------------ |
| open | Opening a file | function | String filePath,{String? type, String? uti} | Future<File> | yes          |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

| Name     | Description                   | Type   | Input | Output | ohos Support |
| -------- | ----------------------------- | ------ | ----- | ------ | ------------ |
| fileName | Path to the file to be opened | String | /     | /      | yes          |
| type     | MIME type hint for the file   | String | /     | /      | yes          |
| uti      | Uniform Type Identifier       | String | /     | /      | yes          |

## 5. Known Issues

## 6. Others

## 7. License

This project is licensed under [The BSD-3-Clause License](./LICENSE).
