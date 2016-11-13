package kobayashi.taku.com.citore;

import android.net.Uri;
import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import com.google.gson.Gson;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Objects;

import okhttp3.Response;
import okhttp3.ResponseBody;

public class MainActivity extends AppCompatActivity {
    private TweetVoice mVoice;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
//        ApplicationHelper.requestPermissions(this, 1);

        Uri.Builder builder = new Uri.Builder();
        builder.scheme("http");
        builder.authority("taptappun.cloudapp.net");
        builder.path("/tweet_voice/search");
        builder.appendQueryParameter("text", "オナモミ");
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
                }
            });
            breq.execute(builder.toString());
        }
    }
}
