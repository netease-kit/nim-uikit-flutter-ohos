// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:netease_corekit/report/xkit_report_constants.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

typedef ReportItem = Map<String, dynamic>;

class XKitReporter {
  static const _tag = 'XKitReporter';

  /// 上报地址
  static const _reportUrl =
      'https://statistic.live.126.net/statics/report/xkit/action';

  /// http 请求成功 code
  static const _httpCodeSuccess = 200;

  /// 缓存最大数，默认 10
  static const _cacheCount = 10;

  /// api 超时时间， 10s
  static const _apiTimeOut = 10 * 1000;

  /// 最小检查时间 5s，每次完成一次接口 report 后，延时 [_reportCacheCheckTime] 时间检查当前是否存在未上报的缓存，
  /// 若有则直接上报，否则 [_reportCacheCheckTime] 后取消延时。
  static const _reportCacheCheckTime = 5 * 1000;

  /////////////////  单例实现 start  //////////////
  static late final XKitReporter _instance = XKitReporter._internal();

  XKitReporter._internal();

  factory XKitReporter() => _instance;

  /////////////////  单例实现 end  ///////////////

  /// 待上报的缓存
  final List<ReportItem> _reportCache = [];

  /// 上报中的缓存，上报失败则添加回待上报的缓存
  final Map<int, List<ReportItem>> _reportingMap = {};

  /// api 时间上报缓存
  final LinkedHashMap<int, _ApiEventInfo> _apiEventReportCache =
      LinkedHashMap();

  /// module 信息缓存，key - moduleName, value - moduleVersion
  final Map<String, String> moduleInfoCache = {};

  ///　debug 版本标记
  final bool debugFlag = false;

  /// 基本信息，用户设置的 appKey，imVersion，nertcVersion 等数据
  _BasicInfo? _basicInfo;

  /// 延时检测
  Timer? _checkCacheTask;

  /// 初始化 rtc 版本号，im 版本号， appKey 等数据
  void init(
      {required String? appKey, String? imVersion, String? nertcVersion}) {
    _log(
        'init=> appKeyIsEmpty:${appKey == null},imVersion:$imVersion,nertcVersion:$nertcVersion',
        true);
    _basicInfo = _BasicInfo(appKey, imVersion, nertcVersion);
    _checkReportCacheTask();
  }

  /// 注册模块信息
  void register(
      {required String moduleName,
      required String moduleVersion,
      bool report = true,
      bool rightNow = true}) {
    _log(
        'register=> moduleName:$moduleName,moduleVersion:$moduleVersion,report:$report,rightNow:$rightNow',
        true);
    moduleInfoCache[moduleName] = moduleVersion;
    if (!report) {
      return;
    }
    _reportInit(
        moduleName: moduleName,
        moduleVersion: moduleVersion,
        rightNow: rightNow);
  }

  /// 上报模块初始化
  void reportInit(
      {required String moduleName,
      required String moduleVersion,
      bool rightNow = false}) {
    _log(
        'reportInit=> moduleName:$moduleName,moduleVersion:$moduleVersion,rightNow:$rightNow',
        true);
    moduleInfoCache[moduleName] = moduleVersion;
    _reportInit(
        moduleName: moduleName,
        moduleVersion: moduleVersion,
        rightNow: rightNow);
  }

  /// 上报页面PV
  void reportPV(
      {required String moduleName,
      String? moduleVersion,
      String? page,
      String? user,
      String? extra,
      bool rightNow = false}) {
    _log(
        'reportPV=> moduleName:$moduleName,moduleVersion:$moduleVersion,'
        'page:$page,user:$user,extra:$extra,rightNow:$rightNow',
        true);
    _report(
        _generateItem(moduleName, _getModuleVersion(moduleName, moduleVersion),
            reportTypePV,
            item: {keyUVPage: page, keyUVUser: user, keyExtra: extra}),
        rightNow: rightNow);
  }

  /// 上报页面UV
  void reportUV(
      {required String moduleName,
      String? moduleVersion,
      String? page,
      String? user,
      String? extra,
      bool rightNow = false}) {
    _log(
        'reportUV=> moduleName:$moduleName,moduleVersion:$moduleVersion,'
        'page:$page,user:$user,extra:$extra,rightNow:$rightNow',
        true);
    _report(
        _generateItem(moduleName, _getModuleVersion(moduleName, moduleVersion),
            reportTypeUV,
            item: {keyUVPage: page, keyUVUser: user, keyExtra: extra}),
        rightNow: rightNow);
  }

  /// 上报调用 api 后的异步回调结果
  void reportApiCallbackEvent(
      {required String moduleName,
      String? moduleVersion,
      required String apiCallback,
      String? params,
      String? response,
      required int requestId,
      int? costTime,
      int code = 0,
      int time = 0,
      bool rightNow = false}) {
    final timestamp = time == 0 ? DateTime.now().millisecond : time;
    final item = {
      keyApiCallback: apiCallback,
      keyEventParams: params,
      keyResponse: response,
      keyEventRequestId: requestId,
      keyCode: code,
      keyTime: timestamp,
      keyCostTime: costTime
    };
    _log(
        'reportApiCallbackEvent=> moduleName:$moduleName,moduleVersion:$moduleVersion,'
        'apiCallback:$apiCallback,params:$params,code:$code,response:$response,'
        'time:$time,rightNow:$rightNow,requestId:$requestId,costTime:$costTime',
        true);
    _report(
        _generateItem(moduleName, _getModuleVersion(moduleName, moduleVersion),
            reportTypeEventApi,
            item: item, timestamp: timestamp),
        rightNow: rightNow);
  }

  /// 上报三方外部回调
  void reportCallbackEvent(
      {required String moduleName,
      String? moduleVersion,
      required String callback,
      int code = 0,
      String? response,
      int time = 0,
      bool rightNow = false}) {
    _log(
        'reportCallbackEvent=> moduleName:$moduleName,moduleVersion:$moduleVersion,'
        'callback:$callback,code:$code,response:$response,time:$time,'
        'rightNow:$rightNow',
        true);
    final timestamp = time == 0 ? DateTime.now().millisecond : time;
    _report(
        _generateItem(moduleName, _getModuleVersion(moduleName, moduleVersion),
            reportTypeEventCallback,
            item: {
              keyCallBack: callback,
              keyCode: code,
              keyResponse: response,
              keyTime: timestamp
            },
            timestamp: timestamp),
        rightNow: rightNow);
  }

  /// api 调用上报记录点
  int beginReport(
      {required moduleName,
      String? moduleVersion,
      required String api,
      String? params}) {
    _log(
        'beginReport=> moduleName:$moduleName,moduleVersion:$moduleVersion,'
        'api:$api,params:$params',
        true);
    int requestId = DateTime.now().microsecondsSinceEpoch;
    _apiEventReportCache[requestId] = _ApiEventInfo(
        moduleName,
        api,
        requestId,
        DateTime.now().millisecondsSinceEpoch,
        _getModuleVersion(moduleName, moduleVersion))
      ..params = params;
    return requestId;
  }

  /// api 调用上报包含参数以及结果
  void endReport(
      {required int requestId,
      int code = 0,
      String? response,
      bool rightNow = false}) {
    _log(
        'endReport=> requestId:$requestId,code:$code,response:$response,rightNow:$rightNow',
        true);
    var data = _apiEventReportCache.remove(requestId);
    if (data == null) {
      Alog.e(tag: _tag, content: 'endReport: no entity for key$requestId.');
      return;
    }
    data.code = code;
    data.response = response;
    data.costTime = DateTime.now().millisecondsSinceEpoch - data.time;
    _report(
        _generateItem(data.moduleName, data.moduleVersion, reportTypeEventApi,
            item: data.toReportItem(), timestamp: data.time),
        rightNow: rightNow);
  }

  /// 将缓存中所有未上报数据全部上报
  void flushAll({Duration delayTime = const Duration(seconds: 5)}) {
    _log('flushAll=> delayTime:$delayTime', true);
    Timer(delayTime, () {
      _supplementTimeOutApiEvent();
      if (_basicInfo == null) {
        _log('please call the method XKitReporter().init first.');
        return;
      }
      if (_reportCache.isNotEmpty) {
        _reportToServerWithFailed('flushAll');
      }
    });
  }

  void _reportInit(
      {required String moduleName,
      required String moduleVersion,
      bool rightNow = false}) {
    _report(_generateItem(moduleName, moduleVersion, reportTypeInit),
        rightNow: rightNow);
  }

  /// 上报内部入口 1，立即上报数据，2，检查是否有超时 api 任务并排入上报缓存，3，加入上报缓存，4，开启上报任务延时检查
  void _report(ReportItem item, {bool rightNow = false}) {
    _log('report=> item:$item,rightNow:$rightNow.');
    _supplementTimeOutApiEvent();
    if (rightNow || _cacheCount <= 1) {
      if (_basicInfo == null) {
        _reportCache.add(item);
        _log('please call method XKitReporter()#init first.');
        return;
      }
      _reportToServer(_supplementBasicInfo([item])).then((result) {
        if (!result) {
          _reportCache.add(item);
        }
      });
      _log('report right now.');
      return;
    }
    _log('report cache before adding item is $_reportCache.');
    _reportCache.add(item);
    _log('report cache after adding item is $_reportCache.');
    if (_basicInfo == null) {
      _log('please call method XKitReporter()#init first.');
      return;
    }
    if (_reportCache.length < _cacheCount) {
      _checkReportCacheTask();
    } else {
      _reportToServerWithFailed('_report');
    }
  }

  void _reportToServerWithFailed(String flag) {
    _checkReportCacheTask(false);
    final requestId = DateTime.now().microsecondsSinceEpoch;
    _reportingMap[requestId] = [..._reportCache];
    _reportCache.clear();

    _reportToServer(_supplementBasicInfo(_reportingMap[requestId]))
        .then((result) {
      final reportingData = _reportingMap.remove(requestId);
      if (result) {
        _log('$flag, success clear all.');
      } else {
        _log('$flag, failed back to cache.');
        if (reportingData?.isNotEmpty == true) {
          _reportCache.addAll(reportingData!);
        }
        _checkReportCacheTask();
      }
    }).catchError((e) {
      Alog.e(tag: _tag, content: "$flag _reportToServer error=> $e.");
    });
  }

  /// （取消）延时检查并上报缓存
  void _checkReportCacheTask([bool start = true]) {
    _log('_checkReportCacheTask=> start:$start');
    if (start) {
      _checkCacheTask?.cancel();
      _checkCacheTask =
          Timer(const Duration(milliseconds: _reportCacheCheckTime), () {
        _log('_checkReportCacheTask=> onTimeToFlushAll');
        flushAll(delayTime: const Duration());
      });
    } else {
      _checkCacheTask?.cancel();
    }
  }

  /// 检查并将超时 api 任务添加到上报缓存队列中
  void _supplementTimeOutApiEvent() {
    _log(
        '_supplementTimeOutApiEvent=>_apiEventReportCacheSize:${_apiEventReportCache.length}');
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    _apiEventReportCache.removeWhere((key, value) {
      bool result = currentTime - value.time >= _apiTimeOut;
      if (result) {
        _reportCache.add(_generateItem(
            value.moduleName, value.moduleVersion, reportTypeEventApi,
            item: value.toReportItem(), timestamp: value.time));
      }
      return result;
    });
  }

  /// 真是发起网络请求上报
  Future<bool> _reportToServer(List<ReportItem>? info) async {
    _log('_reportToServer=> info:${info?.toString()}');
    if (info == null) {
      _log('_reportToServer=> info:null');
    }
    final dio = Dio();
    try {
      final response = await dio.post(_reportUrl,
          options: Options(headers: {
            'Connection': 'keep-Alive',
            'Content-Type': 'application/json;charset=utf-8'
          }),
          data: info);
      _log('report response is $response. value info is ${info.toString()}.');
      return response.statusCode == _httpCodeSuccess;
    } catch (e) {
      Alog.e(tag: _tag, content: "_reportToServer dio.post error=> $e.");
      return false;
    }
  }

  /// 获取模块版本号
  String? _getModuleVersion(String moduleName, String? moduleVersion) {
    final version = moduleVersion ?? moduleInfoCache[moduleName];
    if (version == null || version.isEmpty) {
      Alog.e(tag: _tag, content: "module\$$moduleName's version info is null.");
    } else if (moduleInfoCache[moduleName] == null) {
      moduleInfoCache[moduleName] = version;
    }
    return version;
  }

  String _getPlatform() {
    String platform = 'unknown';
    if (Platform.isAndroid) {
      platform = 'Android';
    } else if (Platform.isIOS) {
      platform = 'iOS';
    } else if (Platform.isWindows) {
      platform = 'PC';
    } else if (Platform.isMacOS) {
      platform = 'MAC';
    } else if (Platform.isLinux) {
      platform = 'Linux';
    } else if (kIsWeb) {
      platform = 'Web';
    } else if (Platform.isOhos) {
      platform = 'Ohos';
    }
    return platform;
  }

  List<ReportItem>? _supplementBasicInfo(List<ReportItem>? itemList) {
    itemList?.forEach((element) {
      element[keyAppKey] = _basicInfo?.appKey;
      element[keyImVersion] = _basicInfo?.imVersion;
      element[keyNertcVersion] = _basicInfo?.nertcVersion;
      element[keyPlatform] = _getPlatform();
      element[kFramework] = framework;
      element[keyOs] = _getPlatform();
      element[keyLanguage] = language;
    });
    return itemList;
  }

  /// 根据字段生成 [ReportItem]
  ReportItem _generateItem(
      String moduleName, String? moduleVersion, String type,
      {ReportItem? item, int timestamp = 0}) {
    //item 里面不传内容
    // if (item == null) {
    //   item = {runPlatform: _getPlatform()};
    // } else {
    //   item[runPlatform] = _getPlatform();
    // }
    return {
      keyComponent: moduleName,
      keyVersion: moduleVersion,
      keyTimestamp:
          timestamp <= 0 ? DateTime.now().millisecondsSinceEpoch : timestamp,
      keyReportType: type,
      keyData: item
    };
  }

  void _log(String content, [bool isApi = false]) {
    if (!debugFlag) {
      return;
    }
    Alog.d(
        tag: _tag,
        type: isApi ? AlogType.api : AlogType.normal,
        content: 'time:${DateTime.now()},$content');
  }
}

class _ApiEventInfo {
  String moduleName;
  String? moduleVersion;
  String api;
  String? params;
  int code = 0;
  String? response;
  int requestId;
  int time = 0;
  int? costTime;

  _ApiEventInfo(this.moduleName, this.api, this.requestId, this.time,
      [this.moduleVersion]);

  ReportItem toReportItem() {
    return {
      keyApi: api,
      keyEventParams: params,
      keyCode: code,
      keyResponse: response,
      keyEventRequestId: requestId,
      keyTime: time,
      keyCostTime: costTime,
    };
  }
}

class _BasicInfo {
  String? appKey;
  String? imVersion;
  String? nertcVersion;
  String platform = 'Flutter';

  _BasicInfo(this.appKey, this.imVersion, this.nertcVersion);
}

extension RequestIdExtension on int {
  void endReport({int code = 0, String? response, bool rightNow = false}) {
    XKitReporter().endReport(
        requestId: this, code: code, response: response, rightNow: rightNow);
  }
}
