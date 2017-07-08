package kobayashi.taku.com.citore;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Environment;
import android.preference.PreferenceActivity;
import android.speech.tts.TextToSpeech;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.google.gson.Gson;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Locale;
import java.util.Objects;

import okhttp3.Response;
import okhttp3.ResponseBody;

public class MainActivity extends Activity {
    private static int REQUEST_CODE = 1;
    private TweetVoice mVoice;
    private LoopSpeechRecognizer mLoopSpeechRecognizer;
    private TextToSpeech mTTS;
    //private EditText mEditText;
    //private TextView mRecordText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        ApplicationHelper.requestPermissions(this, REQUEST_CODE);
        mTTS = new TextToSpeech(this, new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if (TextToSpeech.SUCCESS == status) {
                    Locale locale = Locale.JAPANESE;
                    if (mTTS.isLanguageAvailable(locale) >= TextToSpeech.LANG_AVAILABLE) {
                        mTTS.setLanguage(locale);
                    } else {
                        Log.d("", "Error SetLocale");
                    }
                    if (mTTS.isSpeaking()) {
                        // 読み上げ中なら止める
                        mTTS.stop();
                    }

                    // 読み上げ開始
                    String utteranceId = String.valueOf(this.hashCode());
                    mTTS.speak("オナモミ", TextToSpeech.QUEUE_FLUSH, null, utteranceId);
                } else {
                    Log.d("", "Error Init");
                }
            }
        });

        setContentView(R.layout.activity_main);

        /*
        mLoopSpeechRecognizer = new LoopSpeechRecognizer(this);
        setupRecordingButtonText();
        Button recordingButton = (Button) findViewById(R.id.recording_button);
        recordingButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                changeRecordState();
                setupRecordingButtonText();
            }
        });
        */
        ApplicationHelper.requestPermissions(this, 1);

        /*
        mEditText = (EditText) findViewById(R.id.debug_text);
        mRecordText = (TextView) findViewById(R.id.recognize_text);

        Button debugButton = (Button) findViewById(R.id.debug_button);
        debugButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                requestServer(mEditText.getEditableText().toString());
            }
        });
        mLoopSpeechRecognizer = new LoopSpeechRecognizer(this);
//        ApplicationHelper.requestPermissions(this, 1);

        mLoopSpeechRecognizer.setCallback(new LoopSpeechRecognizer.RecognizeCallback() {
            @Override
            public void onSuccess(float confidence, String value) {
                Log.d(Config.TAG, "value:" + value);
                mRecordText.setText(value);
                requestServer(value);
            }
        });
*/
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mTTS != null) {
            // TextToSpeechのリソースを解放する
            mTTS.shutdown();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if(REQUEST_CODE == requestCode){
            Log.d(Config.TAG, String.valueOf(requestCode));
        }
    }

    private void setupRecordingButtonText(){
        Button recordingButton = (Button) findViewById(R.id.recording_button);
        SharedPreferences sp = getSharedPreferences(getPackageName(), Context.MODE_PRIVATE);
        if(sp.getBoolean(getString(R.string.recoarding_key), false)){
            recordingButton.setText(getString(R.string.recoarding_now));
        }else{
            recordingButton.setText(getString(R.string.recoarding_start));
        }
    }

    private void changeRecordState(){
        SharedPreferences sp = getSharedPreferences(getPackageName(), Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        String recordingKey = getString(R.string.recoarding_key);
        if(sp.getBoolean(recordingKey, false)){
            Log.d(Config.TAG, "stopService");
            editor.putBoolean(recordingKey, false);
            mLoopSpeechRecognizer.stopListening();
//            stopService(new Intent(this, VoiceRecordService.class));
        }else{
            mLoopSpeechRecognizer.setCallback(new LoopSpeechRecognizer.RecognizeCallback() {
                @Override
                public void onSuccess(float confidence, String value) {
                    Log.d(Config.TAG, "value:" + value);
                    requestServer(value);
                }
            });
            mLoopSpeechRecognizer.startListening();
            Log.d(Config.TAG, "startService");
            editor.putBoolean(recordingKey, true);
//            startService(new Intent(this, VoiceRecordService.class));
        }
        editor.apply();
    }

    private void requestServer(String value){
        Log.d(Config.TAG, "value:" + value);
        Uri.Builder builder = new Uri.Builder();
        builder.scheme("https");
        builder.authority("taptappun.net");
        builder.path("/citore/voice/search");
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
        req.execute(builder.toString());
    }

    @Override
    protected void onResume() {
        super.onResume();
        //mLoopSpeechRecognizer.startListening();
    }

    @Override
    protected void onPause() {
        super.onPause();
        //mLoopSpeechRecognizer.stopListening();
    }

    private void getVoiceFile(TweetVoice voice){
        if(voice != null){
            mVoice = voice;
            //http://taptappun.cloudapp.net/tweet_voice/download?tweet_voice_id=3
            Uri.Builder builder = new Uri.Builder();
            builder.scheme("https");
            builder.authority("taptappun.net");
            builder.path("/citore/voice/download");
            builder.appendQueryParameter("key", voice.key);
            builder.appendQueryParameter("reading", voice.reading);
            builder.appendQueryParameter("file_name", voice.file_name);
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
                    String filename = mVoice.file_name;
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
