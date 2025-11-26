/*
* Copyright (c) 2024 SwanLink (Jiangsu) Technology Development Co., LTD.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import {
  MethodCallHandler,
  FlutterPlugin,
  BinaryMessenger,
  FlutterPluginBinding,
  AbilityPluginBinding,
  MethodCall,
  MethodChannel,
  MethodResult,
  Log,
  AbilityAware,
} from '@ohos/flutter_ohos';
import { UIAbility, Want, wantConstant } from '@kit.AbilityKit';
import { HashMap } from '@kit.ArkTS';
import { AllType, FileViewType } from './FileType';
import {
  CAN_NOT_MATCH_ANY_COMPONENT,
  FILE_PROTOCOL_HEADER,
  HARMONY_OS_PHOTOS_ABILITY_NAME,
  HARMONY_OS_PHOTOS_BUNDLE_NAME,
  OHOS_WANT_ACTION_SEND_DATA,
  OHOS_WANT_ACTION_VIEW_DATA,
  PHOTO_PROTOCOL_HEADER
} from './commonInformation';
import { fileIo } from '@kit.CoreFileKit';
import { ResultType } from './ResultType';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = "OpenFilePlugin";

export default class OpenFilePlugin implements MethodCallHandler, FlutterPlugin, AbilityAware {
  private flutterPluginBinding: FlutterPluginBinding | null = null;
  private channel: MethodChannel | null = null;
  private ability: UIAbility | null = null;
  private isResultSubmitted: boolean = false;
  private result: MethodResult | null = null;
  private filePath: string = '';
  private typeString: string = '';
  private action: string = OHOS_WANT_ACTION_VIEW_DATA;

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.flutterPluginBinding = binding;
    this.setup(binding.getBinaryMessenger());
  }

  private setup(messenger: BinaryMessenger) {
    this.channel = new MethodChannel(messenger, "open_file")
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel == null) {
      // Could be on too low of an SDK to have started listening originally.
      return
    }
    this.channel?.setMethodCallHandler(null)
    this.channel = null
    this.flutterPluginBinding = null
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.ability = binding.getAbility()
  }

  onDetachedFromAbility(): void {
    if (this.channel == null) {
      return
    }
    this.channel?.setMethodCallHandler(null)
    this.channel = null
    this.ability = null
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.isResultSubmitted = false
    if (call.method == "open_file") {
      this.result = result
      const path = call.argument("file_path") as string ?? ''
      if (!this.isFileAvailable(path)) {
        return
      }
      if (call.hasArgument("type") && call.argument("type")) {
        this.typeString = call.argument("type");
      } else {
        this.typeString = this.getFileType(this.filePath);
      }
      this.startAbility();
    } else {
      result.notImplemented()
      this.isResultSubmitted = true
    }
  }

  private isFileAvailable(path?: string): boolean {
    if (!path) {
      this.onResult(ResultType.error, "the file path cannot be null");
      return false;
    }
    this.filePath = this.processPath(path);
    let file: fileIo.File | undefined;
    try {
      file = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_ONLY);
      if (file) {
        fileIo.closeSync(file);
        return true;
      }
    } catch (e) {
      Log.e(TAG, `readImage failed:${JSON.stringify(e)}`);
    }
    this.onResult(ResultType.fileNotFound, "the " + this.filePath + " file does not exists");
    return false;
  }

  private processPath(path: string): string {
    if (path.includes(FILE_PROTOCOL_HEADER)) {
      return path
    }
    if (path.substring(0, 1) == "/") {
      return "file:/" + path
    }
    return "file://" + path
  }

  private getFileType(filePath: string): string {
    let fileTypeStr: string = filePath.substring(filePath.lastIndexOf('.') + 1);
    this.getWantAction(fileTypeStr)
    if (AllType.has(fileTypeStr)) {
      return AllType.get(fileTypeStr)!
    } else {
      return "*/*";
    }
  }

  private isMediaStorePath(path: string): boolean {
    return path.includes(PHOTO_PROTOCOL_HEADER);
  }

  private startAbility() {
    const want: Want = this.getWantInfo(this.filePath);
    let type: number = ResultType.done;
    let message: string = "done";
    try {
      this.ability?.context.startAbility(want);
    } catch (error) {
      let e = error as BusinessError;
      Log.i(TAG, `startAbility failed:${JSON.stringify(e)}`);
      if (e.code = CAN_NOT_MATCH_ANY_COMPONENT) {
        type = ResultType.noAppToOpen;
        message = "No APP found to open this file。";
      } else {
        type = ResultType.error;
        message = "File opened incorrectly。";
      }
    }
    this.onResult(type, message);
  }

  private getWantInfo(path: string): Want {
    let want: Want;
    if (this.isMediaStorePath(path)) {
      want = {
        bundleName: HARMONY_OS_PHOTOS_BUNDLE_NAME,
        abilityName: HARMONY_OS_PHOTOS_ABILITY_NAME,
        action: OHOS_WANT_ACTION_VIEW_DATA,
        parameters: {
          uri: path
        }
      }
    } else {
      want = {
        flags: wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
        action: this.action,
        uri: path,
        type: this.typeString,
      };
    }
    return want;
  }

  private getWantAction(type: string) {
    if (FileViewType.has(type)) {
      this.action = OHOS_WANT_ACTION_VIEW_DATA
    } else {
      this.action = OHOS_WANT_ACTION_SEND_DATA
    }
  }

  private onResult(type: number, message: string) {
    if (this.result != null && !this.isResultSubmitted) {
      let map: HashMap<string, string | number> = new HashMap()
      map.set('type', type)
      map.set('message', message)
      let obj: Record<string, string | number> = {};
      map.forEach((value: string, key: string) => {
        obj[key] = value;
      })
      this.result.success(JSON.stringify(obj));
      this.isResultSubmitted = true;
    }
  }
}

