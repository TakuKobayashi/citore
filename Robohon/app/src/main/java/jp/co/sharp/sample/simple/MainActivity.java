package jp.co.sharp.sample.simple;


import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.google.gson.Gson;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Calendar;
import java.util.List;

import jp.co.sharp.android.voiceui.VoiceUIManager;
import jp.co.sharp.android.voiceui.VoiceUIVariable;
import jp.co.sharp.sample.simple.customize.ScenarioDefinitions;
import jp.co.sharp.sample.simple.util.VoiceUIManagerUtil;
import jp.co.sharp.sample.simple.util.VoiceUIVariableUtil;
import jp.co.sharp.sample.simple.util.VoiceUIVariableUtil.VoiceUIVariableListHelper;
import okhttp3.ResponseBody;


/**
 * 音声UIを利用した基本的な機能だけ実装したActivity.
 */
public class MainActivity extends Activity implements MainActivityVoiceUIListener.MainActivityScenarioCallback {
    public static final String TAG = MainActivity.class.getSimpleName();
    private TweetVoice mVoice;
    private LoopSpeechRecognizer mLoopSpeechRecognizer;

    /**
     * 音声UI制御.
     */
    private VoiceUIManager mVoiceUIManager = null;
    /**
     * 音声UIイベントリスナー.
     */
    private MainActivityVoiceUIListener mMainActivityVoiceUIListener = null;
    /**
     * 音声UIの再起動イベント検知.
     */
    private VoiceUIStartReceiver mVoiceUIStartReceiver = null;
    /**
     * ホームボタンイベント検知.
     */
    private HomeEventReceiver mHomeEventReceiver;
    /**
     * UIスレッド処理用.
     */
    private Handler mHandler = new Handler();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.v(TAG, "onCreate()");
        setContentView(R.layout.activity_main);
        mLoopSpeechRecognizer = new LoopSpeechRecognizer(this);

        Intent intent = getIntent();
        if (intent != null) {
            //ホームシナリオから"mode"の値を受け取る.
            String modeVal = intent.getStringExtra("mode");
            if (modeVal != null) {
                ((TextView)findViewById(R.id.mode_value)).setText(modeVal);
            }
            //ホームシナリオから任意の値を受け取る.
            List<VoiceUIVariable> variables = intent.getParcelableArrayListExtra("VoiceUIVariable");
            if (variables != null) {
                String test1 = VoiceUIVariableUtil.getVariableData(variables, ScenarioDefinitions.KEY_TEST_1);
                String test2 = VoiceUIVariableUtil.getVariableData(variables, ScenarioDefinitions.KEY_TEST_2);
                ((TextView)findViewById(R.id.test_value)).setText(test1 + ", " + test2);
            }else{
                Log.d(TAG, "VoiceUIVariable is null");
            }
        }

        // accostボタン
        Button voiceAccostButton = (Button)findViewById(R.id.voice_accost_button);
        voiceAccostButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mVoiceUIManager != null) {
                    VoiceUIVariableListHelper helper = new VoiceUIVariableListHelper().addAccost(ScenarioDefinitions.ACC_ACCOST);
                    VoiceUIManagerUtil.updateAppInfo(mVoiceUIManager, helper.getVariableList(), true);
                }
            }
        });

        // resolve variableボタン
        Button resolveButton = (Button)findViewById(R.id.resolve_variable_button);
        resolveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mVoiceUIManager != null) {
                    VoiceUIVariableListHelper helper = new VoiceUIVariableListHelper().addAccost(ScenarioDefinitions.ACC_RESOLVE);
                    VoiceUIManagerUtil.updateAppInfo(mVoiceUIManager, helper.getVariableList(), true);
                }
            }
        });

        // set memory_pボタン
        Button getMemoryPButton = (Button)findViewById(R.id.set_memoryP);
        getMemoryPButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Calendar now = Calendar.getInstance();

                final String hour = String.valueOf(now.get(Calendar.HOUR_OF_DAY));
                final String minute = String.valueOf(now.get(Calendar.MINUTE));
                int ret = VoiceUIVariableUtil.setVariableData(mVoiceUIManager, ScenarioDefinitions.MEM_P_HOUR, hour);
                if(ret == VoiceUIManager.VOICEUI_ERROR){
                    Log.d(TAG, "setVariableData:VARIABLE_REGISTER_FAILED");
                }
                ret = VoiceUIVariableUtil.setVariableData(mVoiceUIManager, ScenarioDefinitions.MEM_P_MINUTE, minute);
                if(ret == VoiceUIManager.VOICEUI_ERROR){
                    Log.d(TAG, "setVariableData:VARIABLE_REGISTER_FAILED");
                }
                String text = "Set " + hour + ":" + minute;
                TextView textSetting = (TextView)findViewById(R.id.ViewTime);
                textSetting.setText(text);
            }
        });

        // get memory_pボタン
        Button setMemoryPButton = (Button)findViewById(R.id.get_memoryP);
        setMemoryPButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mVoiceUIManager != null) {
                    VoiceUIVariableListHelper helper = new VoiceUIVariableListHelper().addAccost(ScenarioDefinitions.ACC_GET_MEMORYP);
                    VoiceUIManagerUtil.updateAppInfo(mVoiceUIManager, helper.getVariableList(), true);
                }
            }
        });

        // finish app：アプリ終了ボタン
        Button finishAppButton = (Button)findViewById(R.id.finish_app_button);
        finishAppButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mVoiceUIManager != null) {
                    VoiceUIVariableListHelper helper = new VoiceUIVariableListHelper().addAccost(ScenarioDefinitions.ACC_END_APP);
                    VoiceUIManagerUtil.updateAppInfo(mVoiceUIManager, helper.getVariableList(), true);
                }
            }
        });

        //ホームボタンの検知登録.
        mHomeEventReceiver = new HomeEventReceiver();
        IntentFilter filterHome = new IntentFilter(Intent.ACTION_CLOSE_SYSTEM_DIALOGS);
        registerReceiver(mHomeEventReceiver, filterHome);

        //VoiceUI再起動の検知登録.
        mVoiceUIStartReceiver = new VoiceUIStartReceiver();
        IntentFilter filter = new IntentFilter(VoiceUIManager.ACTION_VOICEUI_SERVICE_STARTED);
        registerReceiver(mVoiceUIStartReceiver, filter);

        mLoopSpeechRecognizer.setCallback(new LoopSpeechRecognizer.RecognizeCallback() {
            @Override
            public void onSuccess(float confidence, String value) {
                Log.d(Config.TAG, "value:" + value);
                Uri.Builder builder = new Uri.Builder();
                builder.scheme("http");
                builder.authority("taptappun.cloudapp.net");
                builder.path("/tweet_voice/search");
                builder.appendQueryParameter("text", value);
                JsonRequest req = new JsonRequest();
                req.addCallback(new JsonRequest.ResponseCallback() {
                    @Override
                    public void onSuccess(String url, String body) {
                        Log.d(Config.TAG, "url:" + url + " body:" + body);
                        Gson gson = new Gson();
                        TweetVoice voice = gson.fromJson(body, TweetVoice.class);
                        getVoiceFile(voice);
                    }
                });
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.v(TAG, "onResume()");
        mLoopSpeechRecognizer.startListening();

        //VoiceUIManagerのインスタンス取得.
        if (mVoiceUIManager == null) {
            mVoiceUIManager = VoiceUIManager.getService(getApplicationContext());
        }
        //MainActivityVoiceUIListener生成.
        if (mMainActivityVoiceUIListener == null) {
            mMainActivityVoiceUIListener = new MainActivityVoiceUIListener(this);
        }
        //VoiceUIListenerの登録.
        VoiceUIManagerUtil.registerVoiceUIListener(mVoiceUIManager, mMainActivityVoiceUIListener);

        //Scene有効化.
        VoiceUIManagerUtil.enableScene(mVoiceUIManager, ScenarioDefinitions.SCENE_COMMON);
    }

    @Override
    public void onPause() {
        super.onPause();
        Log.v(TAG, "onPause()");
        mLoopSpeechRecognizer.stopListening();

        //バックに回ったら発話を中止する.
        VoiceUIManagerUtil.stopSpeech();

        //VoiceUIListenerの解除.
        VoiceUIManagerUtil.unregisterVoiceUIListener(mVoiceUIManager, mMainActivityVoiceUIListener);

        //Scene無効化.
        VoiceUIManagerUtil.disableScene(mVoiceUIManager, ScenarioDefinitions.SCENE_COMMON);

        //単一Activityの場合はonPauseでアプリを終了する.
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.v(TAG, "onDestroy()");

        //ホームボタンの検知破棄.
        this.unregisterReceiver(mHomeEventReceiver);

        //VoiceUI再起動の検知破棄.
        this.unregisterReceiver(mVoiceUIStartReceiver);

        //インスタンスのごみ掃除.
        mVoiceUIManager = null;
        mMainActivityVoiceUIListener = null;
    }

    /**
     * VoiceUIListenerクラスからのコールバックを実装する.
     */
    @Override
    public void onExecCommand(String command, List<VoiceUIVariable> variables) {
        Log.v(TAG, "onExecCommand() : " + command);
        switch (command) {
            case ScenarioDefinitions.FUNC_END_APP:
                finish();
                break;
            case ScenarioDefinitions.FUNC_RECOG_TALK:
                final String lvcsr = VoiceUIVariableUtil.getVariableData(variables, ScenarioDefinitions.KEY_LVCSR_BASIC);
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if(!isFinishing()) {
                            ((TextView) findViewById(R.id.recog_text)).setText("Lvcsr:"+lvcsr);
                        }
                    }
                });
                break;
            default:
                break;
        }
    }

    /**
     * ホームボタンの押下イベントを受け取るためのBroadcastレシーバークラス.<br>
     * <p/>
     * アプリは必ずホームボタンで終了する..
     */
    private class HomeEventReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.v(TAG, "Receive Home button pressed");
            // ホームボタン押下でアプリ終了する.
            finish();
        }
    }

    /**
     * 音声UI再起動イベントを受け取るためのBroadcastレシーバークラス.<br>
     * <p/>
     * 稀に音声UIのServiceが再起動することがあり、その場合アプリはVoiceUIの再取得とListenerの再登録をする.
     */
    private class VoiceUIStartReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (VoiceUIManager.ACTION_VOICEUI_SERVICE_STARTED.equals(action)) {
                Log.d(TAG, "VoiceUIStartReceiver#onReceive():VOICEUI_SERVICE_STARTED");
                //VoiceUIManagerのインスタンス取得.
                mVoiceUIManager = VoiceUIManager.getService(getApplicationContext());
                if (mMainActivityVoiceUIListener == null) {
                    mMainActivityVoiceUIListener = new MainActivityVoiceUIListener(getApplicationContext());
                }
                //VoiceUIListenerの登録.
                VoiceUIManagerUtil.registerVoiceUIListener(mVoiceUIManager, mMainActivityVoiceUIListener);
            }
        }
    }


    private void getVoiceFile(TweetVoice voice){
        if(voice != null){
            mVoice = voice;
            //http://taptappun.cloudapp.net/tweet_voice/download?tweet_voice_id=3
            Uri.Builder builder = new Uri.Builder();
            builder.scheme("http");
            builder.authority("taptappun.cloudapp.net");
            builder.path("/tweet_voice/download");
            builder.appendQueryParameter("tweet_voice_id", String.valueOf(voice.id));
            BinaryRequest breq = new BinaryRequest();
            breq.addCallback(new BinaryRequest.ResponseCallback() {
                private ResponseBody mResponse;
                @Override
                public void onSuccess(String url, ResponseBody response) {
                    Log.d(Config.TAG, "url:" + url);
                    String mydirName = "citore";
                    File myDir = new File(Environment.getExternalStorageDirectory(), mydirName);
                    if (!myDir.exists()) { //MyDirectoryというディレクトリーがなかったら作成
                        myDir.mkdirs();
                    }
                    String filename = mVoice.speech_file_path;
                    File saveFile = new File(myDir, filename);
                    InputStream is = response.byteStream();
                    BufferedInputStream input = new BufferedInputStream(is);

                    Log.d(Config.TAG, saveFile.getPath());
                    try {
                        FileOutputStream outputStream = new FileOutputStream(saveFile);
                        byte[] data = new byte[1024];
                        int count = 0;
                        long total = 0;

                        while ((count = input.read(data)) != -1) {
                            total += count;
                            outputStream.write(data, 0, count);
                        }

                        outputStream.flush();
                        outputStream.close();
                        input.close();
                    } catch (IOException e) {
                        Log.d(Config.TAG, "error:" + e.getMessage());
                    }
                    mVoice = null;
                    MediaPlayer mp = MediaPlayer.create(MainActivity.this, Uri.fromFile(saveFile));
                    mp.start();
                }
            });
            breq.execute(builder.toString());
        }
    }
}
