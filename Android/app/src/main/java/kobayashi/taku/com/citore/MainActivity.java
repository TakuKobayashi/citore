package kobayashi.taku.com.citore;

import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.Objects;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        HashMap<String, Object> params = new HashMap<String, Object>();
        params.put("text", "オナモミ");
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
            }
        });
        req.execute(builder.toString());
    }
}
