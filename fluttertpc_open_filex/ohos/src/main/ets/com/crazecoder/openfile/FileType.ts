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

/**
 * 文件预览器支持格式
 */
export const FileViewType: Map<string, string> = new Map([
  ['txt', 'text/plain'],
  ['cpp', 'text/x-c++src'],
  ['c', 'text/x-csrc'],
  ['h', 'text/x-chdr'],
  ['java', 'text/x-java'],
  ['xhtml', 'application/xhtml+xml'],
  ['xml', 'text/xml'],
  ['html', 'text/html'],
  ['htm', 'text/html'],
  ['mp4', 'video/mp4'],
  ['mkv', 'video/x-matroska'],
  ['ts', 'video/mp2ts'],
  ['jpg', 'image/jpeg'],
  ['jpeg', 'image/jpeg'],
  ['png', 'image/png'],
  ['gif', 'image/gif'],
  ['webp', 'image/webp'],
  ['bmp', 'image/bmp'],
  ['svg', 'image/svg+xml'],
  ['m4a', 'audio/mp4a-latm'],
  ['aac', 'audio/aac'],
  ['mp3', 'audio/mpeg'],
  ['ogg', 'audio/ogg'],
  ['wav', 'audio/x-wav'],
  ['pdf', 'application/pdf']
])

/**
 * 文本类型格式
 */
export const TextType: Map<string, string> = new Map([
  ['txt', 'text/plain'],
  ['cpp', 'text/x-c++src'],
  ['c', 'text/x-csrc'],
  ['h', 'text/x-chdr'],
  ['java', 'text/x-java'],
  ['xhtml', 'application/xhtml+xml'],
  ['xml', 'text/xml'],
  ['html', 'text/html'],
  ['htm', 'text/html'],
  ['conf', 'text/plain'],
  ['log', 'text/plain'],
  ['prop', 'text/plain'],
  ['rc', 'text/plain'],
  ['sh', 'text/plain']
])

/**
 * 视频类型格式
 */
export const VideoType: Map<string, string> = new Map([
  ['mp4', 'video/mp4'],
  ['mkv', 'video/x-matroska'],
  ['ts', 'video/mp2ts'],
  ['3gp', 'video/3gpp'],
  ['asf', 'video/x-ms-asf'],
  ['avi', 'video/x-msvideo'],
  ['m4u', 'video/vnd.mpegurl'],
  ['m4v', 'video/x-m4v'],
  ['mov', 'video/quicktime'],
  ['mpe', 'video/mpeg'],
  ['mpeg', 'video/mpeg'],
  ['mpg', 'video/mpeg'],
  ['mpg4', 'video/mp4']
])

/**
 * 图片类型格式
 */
export const ImageType: Map<string, string> = new Map([
  ['jpg', 'image/jpeg'],
  ['jpeg', 'image/jpeg'],
  ['png', 'image/png'],
  ['gif', 'image/gif'],
  ['webp', 'image/webp'],
  ['bmp', 'image/bmp'],
  ['svg', 'image/svg+xml']
])

/**
 * 音频类型格式
 */
export const AudioType: Map<string, string> = new Map([
  ['m4a', 'audio/mp4a-latm'],
  ['aac', 'audio/aac'],
  ['mp3', 'audio/mpeg'],
  ['ogg', 'audio/ogg'],
  ['wav', 'audio/x-wav'],
  ['m3u', 'audio/x-mpegurl'],
  ['m4b', 'audio/mp4a-latm'],
  ['m4p', 'audio/mp4a-latm'],
  ['mp2', 'audio/x-mpeg'],
  ['mpga', 'audio/mpeg'],
  ['mpe', 'audio/mpeg'],
  ['rmvb', 'audio/x-pn-realaudio'],
  ['wma', 'audio/x-ms-wma'],
  ['wmv', 'audio/x-ms-wmv']
])

/**
 * 其它应用类型格式
 */
export const ApplicationType: Map<string, string> = new Map([
  ['torrent', 'application/x-bittorrent'],
  ['kml', 'application/vnd.google-earth.kml+xml'],
  ['gpx', 'application/gpx+xml'],
  ['apk', 'application/vnd.android.package-archive'],
  ['bin', 'application/octet-stream'],
  ['class', 'application/octet-stream'],
  ['exe', 'application/octet-stream'],
  ['doc', 'application/msword'],
  ['docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
  ['xls', 'application/vnd.ms-excel'],
  ['csv', 'application/vnd.ms-excel'],
  ['xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
  ['gtar', 'application/x-gtar'],
  ['gz', 'application/x-gzip'],
  ['jar', 'application/java-archive'],
  ['js', 'application/x-javascript'],
  ['mpc', 'application/vnd.mpohun.certificate'],
  ['msg', 'application/vnd.ms-outlook'],
  ['pdf', 'application/pdf'],
  ['pps', 'application/vnd.ms-powerpoint'],
  ['ppt', 'application/vnd.ms-powerpoint'],
  ['pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation'],
  ['rtf', 'application/rtf'],
  ['tar', 'application/x-tar'],
  ['tgz', 'application/x-compressed'],
  ['wps', 'application/vnd.ms-works'],
  ['z', 'application/x-compress'],
  ['zip', 'application/x-zip-compressed']
])

/**
 * 所有类型格式
 */
export const AllType: Map<string, string> = new Map([
  ...TextType, ...VideoType, ...ImageType, ...AudioType, ...ApplicationType
])