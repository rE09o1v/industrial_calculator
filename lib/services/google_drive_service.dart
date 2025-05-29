import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/calculation_data.dart';
import 'storage_service.dart';

class GoogleDriveService {
  final StorageService _storageService = StorageService();
  final _scopes = [drive.DriveApi.driveFileScope];
  
  // プラットフォームに応じたGoogleSignInインスタンスを取得
  GoogleSignIn get _googleSignIn {
    if (kIsWeb) {
      // Web用の設定
      return GoogleSignIn(
        scopes: [drive.DriveApi.driveFileScope],
        clientId: '549512761201-75f006f46211dtffa1hbk27ibd6eloou.apps.googleusercontent.com', // Google Cloud ConsoleのOAuthクライアントID
      );
    } else {
      // Android/iOS用の設定
      return GoogleSignIn(
        scopes: [drive.DriveApi.driveFileScope],
      );
    }
  }

  // Google Driveへサインイン
  Future<drive.DriveApi?> _signInToDrive() async {
    try {
      debugPrint('Google Sign-In を開始します...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('ユーザーがサインインをキャンセルしました。');
        return null;
      }

      debugPrint('サインイン成功: ${account.email}');
      final GoogleSignInAuthentication auth = await account.authentication;
      
      if (auth.accessToken == null) {
        debugPrint('アクセストークンの取得に失敗しました。');
        return null;
      }
      
      debugPrint('アクセストークン取得成功');
      final Map<String, String> authHeaders = {
        'Authorization': 'Bearer ${auth.accessToken}',
        'X-Goog-AuthUser': '0',
      };

      final authenticateClient = _GoogleAuthClient(authHeaders);
      return drive.DriveApi(authenticateClient);
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      // スタックトレースも表示
      debugPrintStack(stackTrace: StackTrace.current);
      return null;
    }
  }

  // 計算データをバックアップ
  Future<bool> backupCalculations() async {
    try {
      debugPrint('バックアップ処理を開始します...');
      // サインイン
      final drive.DriveApi? driveApi = await _signInToDrive();
      if (driveApi == null) {
        debugPrint('Google Driveへのサインインに失敗しました。');
        return false;
      }

      // すべての保存データを取得
      debugPrint('保存されたデータを取得中...');
      final List<CalculationData> allCalculations = 
          await _storageService.getAllSavedCalculations();
      
      if (allCalculations.isEmpty) {
        debugPrint('バックアップするデータがありません。');
        return false;
      }

      debugPrint('${allCalculations.length}件のデータをバックアップします。');
      // JSONに変換
      final String jsonData = jsonEncode(
        allCalculations.map((calc) => calc.toJson()).toList()
      );
      
      // 一時ファイル作成
      debugPrint('一時ファイルを作成中...');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/industrial_calc_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await tempFile.writeAsString(jsonData);
      debugPrint('一時ファイル作成完了: ${tempFile.path}');
      
      // Drive APIでアップロード
      debugPrint('Google Driveにアップロード中...');
      final drive.File driveFile = drive.File()
        ..name = 'industrial_calc_backup_${DateTime.now().toString().substring(0, 19)}.json'
        ..mimeType = 'application/json'
        ..description = '工場設備計算アプリのバックアップデータ';
      
      // ファイルのアップロード
      await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(tempFile.openRead(), tempFile.lengthSync()),
      );
      
      // 一時ファイル削除
      await tempFile.delete();
      
      debugPrint('バックアップ完了!');
      return true;
    } catch (e) {
      debugPrint('Backup Error: $e');
      debugPrintStack(stackTrace: StackTrace.current);
      return false;
    }
  }
  
  // 前回のバックアップを復元
  Future<bool> restoreLatestBackup() async {
    try {
      // サインイン
      final drive.DriveApi? driveApi = await _signInToDrive();
      if (driveApi == null) {
        return false;
      }
      
      // バックアップファイル検索
      final drive.FileList fileList = await driveApi.files.list(
        q: "name contains 'industrial_calc_backup' and mimeType = 'application/json'",
        orderBy: 'createdTime desc',
      );
      
      if (fileList.files == null || fileList.files!.isEmpty) {
        return false;
      }
      
      // 最新のバックアップファイルを取得
      final latestBackup = fileList.files!.first;
      
      // ファイルの内容をダウンロード
      final drive.Media? media = await driveApi.files.get(
        latestBackup.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media?;
      
      if (media == null) {
        return false;
      }
      
      // 一時ファイルにダウンロード
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_restore.json');
      
      final List<int> dataBytes = [];
      await media.stream.forEach((element) {
        dataBytes.addAll(element);
      });
      
      await tempFile.writeAsBytes(dataBytes);
      
      // JSONを解析
      final String jsonContent = await tempFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonContent);
      
      // 現在のデータをクリア（オプション）
      await _storageService.clearAllCalculations();
      
      // 各データを保存
      for (var json in jsonList) {
        final calculationData = CalculationData.fromJson(json);
        await _storageService.saveCalculationData(calculationData);
      }
      
      // 一時ファイル削除
      await tempFile.delete();
      
      return true;
    } catch (e) {
      debugPrint('Restore Error: $e');
      return false;
    }
  }

  // サインアウト
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

// Google認証ヘッダー付きHTTPクライアント
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
} 