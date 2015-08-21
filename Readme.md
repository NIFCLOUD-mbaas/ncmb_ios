# ニフティクラウド mobile backend iOS SDKについて

## 概要

ニフティクラウド mobile backend iOS SDKは、
モバイルアプリのバックエンド機能を提供するクラウドサービス
[ニフティクラウド mobile backend](http://mb.cloud.nifty.com)用のiOS SDKです。

- プッシュ通知
- データストア
- 会員管理
- ファイルストア
- SNS連携

といった機能をアプリから利用することが可能です。

このSDKを利用する前に、ニフティクラウドmobile backendのアカウントを作成する必要があります。

アカウント作成後のSDK導入手順については、
[クイックスタート](http://mb.cloud.nifty.com/doc/quickstart_ios.html)をご覧ください。

## 動作環境

- iOS 5.1 〜 iOS 9.x
 - SNS連携を利用する場合にiOS 9向けの対応を実施する必要があります
 - [SDKガイド:SNS連携](http://mb.cloud.nifty.com/doc/current/sdkguide/ios/sns.html#iOS%209対応について)をご覧ください。
- Xcode6.x、Xcode7.x
- armv7, armv7s, arm64アーキテクチャ
- Facebookアカウントでの会員登録機能を利用する場合は、[Facebook iOS SDK](https://developers.facebook.com/docs/ios)が必要です。
 - Facebook iOS SDKのv4.xはiOS7以上、v3.xはiOS6以上に依存しています。
 - サポートしたいOSバージョンによって使用するFacebook iOS SDKのバージョンを指定してください。
- Googleアカウントでの会員登録機能を利用する場合は、[Google Sign-in for iOS](https://developers.google.com/identity/sign-in/ios/)の設定が必要です。


## ライセンス

このSDKのライセンスについては、LICENSEファイルをご覧ください。

## 参考URL集

- [ニフティクラウド mobile backend](http://mb.cloud.nifty.com)
- [ドキュメント](http://mb.cloud.nifty.com/doc)
- [ユーザーコミュニティ](https://github.com/NIFTYCloud-mbaas/UserCommunity)



