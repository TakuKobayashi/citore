package kobayashi.taku.com.citore;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;

import com.google.gson.Gson;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;
import okhttp3.ws.WebSocket;
import okhttp3.ws.WebSocketCall;
import okhttp3.ws.WebSocketListener;
import okio.Buffer;

public class WebsocketSampleActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        Request request = new Request.Builder()
                .url("ws://27.133.128.228/cable") // INPUT_YOUR_DOMEINは、heroku openしたときのドメインを指定してください。
                .build();

        OkHttpClient client = new OkHttpClient.Builder()
                .build();
        WebSocketCall call = WebSocketCall.create(client, request);
        call.enqueue(new WebSocketListener() {
            @Override
            public void onOpen(WebSocket webSocket, Response response) {
                Log.d(Config.TAG, "onOpen");
            }

            @Override
            public void onFailure(IOException e, Response response) {
                Log.d(Config.TAG, "onFailure " + response, e);
            }

            @Override
            public void onMessage(ResponseBody message) throws IOException {
                Log.d(Config.TAG, "onMessage " + message.string());
            }

            @Override
            public void onPong(Buffer payload) {
                Log.d(Config.TAG, "onPong");
            }

            @Override
            public void onClose(int code, String reason) {
                Log.d(Config.TAG, "onClose");
            }
        });
        setContentView(R.layout.activity_main);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }
}
