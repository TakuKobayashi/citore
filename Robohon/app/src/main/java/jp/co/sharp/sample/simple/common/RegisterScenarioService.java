package jp.co.sharp.sample.simple.common;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import jp.co.sharp.android.voiceui.VoiceUIManager;

/**
 * シナリオ登録するサービス.
 *
 * <p>assetsにあるシナリオをアプリローカルにコピーして登録する</p>
 */
public class RegisterScenarioService extends Service {
    private static final String TAG = RegisterScenarioService.class.getSimpleName();

    /** サービスで実行するコマンド：シナリオの登録. */
    protected static final int CMD_REQUEST_SCENARIO = 10;
    /** サービスで実行可能なコマンドのキー名. */
    private static final String NAME_KEY_COMMAND = "key_cmd";
    /** home用シナリオフォルダー名. */
    private static final String SCENARIO_FOLDER_HOME = "home";
    /** other用シナリオフォルダー名. */
    private static final String SCENARIO_FOLDER_OTHER = "other";

    private VoiceUIManager mVUIManager;

    public RegisterScenarioService() {
    }

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        if (mVUIManager == null) {
            mVUIManager = VoiceUIManager.getService(getApplicationContext());
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int cmd = intent.getIntExtra(NAME_KEY_COMMAND, -1);
        if (cmd == -1) {
            Log.e(TAG, "onStartCommand:not app key_command" );
            return Service.START_NOT_STICKY;
        }

        Log.d(TAG, "onStartCommand cmd:" + cmd);
        switch (cmd) {
            //シナリオ登録コマンド受信.
            case CMD_REQUEST_SCENARIO:
                //homeシナリオ登録.
                registerScenario(true);
                //home以外のシナリオ登録.
                registerScenario(false);
                stopSelf();
                break;
            default:
                break;
        }
        return Service.START_NOT_STICKY;
    }

    /**
     * サービスにコマンドを送信する.
     *
     * @param context コンテキスト
     * @param baseIntent ベースとなるintent
     * @param command コマンドの指定
     */
    public static void start(Context context, Intent baseIntent, int command) {
        baseIntent.putExtra(NAME_KEY_COMMAND, command);
        baseIntent.setClass(context, RegisterScenarioService.class);
        context.startService(baseIntent);
    }

    /**
     * シナリオの登録を行う.
     */
    private void registerScenario(Boolean home) {

        Log.d(TAG, "registerScenario-S:" + home.toString());

        //基準フォルダー名取得.
        String baseFolderName = this.getBaseFolderName(home);

        //Assetsフォルダーの基準フォルダーのファイル名リストを取得.
        final AssetManager assetManager = getResources().getAssets();
        String[] fileList = null;
        try {
            fileList = assetManager.list(baseFolderName);
        } catch (IOException e){
            e.printStackTrace();
        }

        //ローカルに引数.基準フォルダー作成.
        File localFolder = this.createBaseFolder(baseFolderName);

        //Assetsからローカルへhvmlファイルを全てコピー.
        for(String fileName: fileList)
        {
            if (fileName.endsWith(".hvml")) {
                this.copyHvmlFileFromAssetsToLocal(baseFolderName, localFolder.getPath(), fileName);
            }
        }

        //ローカルフォルダーの基準フォルダーのファイル名リストを取得.
        File[] files = localFolder.listFiles();

        //ローカルフォルダーのhvmlファイルのシナリオを登録する.
        for(File file: files){
            Log.d(TAG, "registerScenario file=" + file.getAbsolutePath());
            int result = VoiceUIManager.VOICEUI_ERROR;
            try {
                if (home == true) {
                    //home用.
                    result = mVUIManager.registerHomeScenario(file.getAbsolutePath());
                } else {
                    //other.
                    result = mVUIManager.registerScenario(file.getAbsolutePath());
                }
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            if(result==VoiceUIManager.VOICEUI_ERROR) Log.e(TAG, "registerScenario:Error");
        }
        Log.d(TAG, "registerScenario-E:" + home.toString());
    }

    /**
     * 基準フォルダー名取得.
     */
    private String getBaseFolderName(Boolean home) {
        if (home == true) {
            //home用.
            return SCENARIO_FOLDER_HOME;
        } else {
            //other.
            return SCENARIO_FOLDER_OTHER;
        }
    }

    /**
     * 基準フォルダー作成.
     */
    private File createBaseFolder(String baseFolderName) {
        File folder = null;
        try {
            folder = new File(this.getApplicationContext().getFilesDir(), baseFolderName);
            if (!folder.exists()) {
                folder.mkdirs();
            }
            folder.setReadable(true, false);
            folder.setWritable(true, false);
            folder.setExecutable(true, false);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return folder;
    }

    /**
     * Assetsからローカルへhvmlファイルをコピー.
     */
    private void copyHvmlFileFromAssetsToLocal(String baseFolderName, String localFolderName, String fileName) {
        File assetsFile = null;
        InputStream inputStream = null;
        File localFile = null;
        FileOutputStream fileOutputStream = null;
        byte[] buffer = null;
        try {
            //   AssetsフォルダのhvmlファイルOpen
            assetsFile = new File(baseFolderName, fileName);
            inputStream = getResources().getAssets().open(assetsFile.getPath());

            //   ローカルフォルダーにhvmlファイル作成
            localFile = new File(localFolderName, fileName);
            if (localFile.exists()) {
                localFile.delete();
            }
            fileOutputStream = new FileOutputStream(localFile.getPath());
            localFile.setReadable(true, false);
            localFile.setWritable(true, false);
            localFile.setExecutable(true, false);
            buffer = new byte[1024];
            int length = 0;
            while ((length = inputStream.read(buffer)) >= 0) {
                fileOutputStream.write(buffer, 0, length);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fileOutputStream != null) {
                try {
                    fileOutputStream.close();
                } catch (Exception e) {
                }
            }
            fileOutputStream = null;

            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (Exception e) {
                }
            }
            inputStream = null;
            buffer = null;
            assetsFile = null;
            localFile = null;
            assetsFile = null;
        }
    }

}
