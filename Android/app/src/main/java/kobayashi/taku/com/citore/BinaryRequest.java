package kobayashi.taku.com.citore;

import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.Gson;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class BinaryRequest extends AsyncTask<String, Void, Map<String, ResponseBody>> {
    private Map<String, Object> mParams = new HashMap<String, Object>();
    private ArrayList<ResponseCallback> callbackList = new ArrayList<ResponseCallback>();

    public BinaryRequest(){
    }

    public void setParams(HashMap<String, Object> params){
        this.mParams = params;
    }

    public void addCallback(ResponseCallback callback){
        callbackList.add(callback);
    }

    @Override
    protected void onCancelled() {
        super.onCancelled();
        callbackList.clear();
    }

    protected Map<String, ResponseBody> doInBackground(String... urls){
        HashMap<String, ResponseBody> urlResponse = new HashMap<String, ResponseBody>();
        OkHttpClient client = new OkHttpClient();
        for(String url : urls){
            Gson gson = new Gson();
            String json = gson.toJson(mParams);
            Log.d(Config.TAG, "url:" + url + " json:" + json);
//            MediaType mediaType = MediaType.parse("application/json; charset=utf-8");
  //          RequestBody body = RequestBody.create(mediaType, json);
            Request.Builder requestBuilder = new Request.Builder();
            requestBuilder.url(url);
            //requestBuilder.post(body);

            Request request = requestBuilder.get().build();
            Response response = null;
            try {
                response = client.newCall(request).execute();
                if(response.isSuccessful()){
                    for (ResponseCallback c : callbackList) {
                        c.onSuccess(url, response.body());
                    }
//                    urlResponse.put(url, response.body());
                }
            } catch (IOException e) {
                e.printStackTrace();
                Log.e(Config.TAG, e.getMessage());
            }
        }
        return urlResponse;
    }

    @Override
    protected void onPostExecute(Map<String, ResponseBody> result) {
        super.onPostExecute(result);
        /*
        for(Map.Entry<String, ResponseBody> e : result.entrySet()) {
            for (ResponseCallback c : callbackList) {
                c.onSuccess(e.getKey(), e.getValue());
            }
        }
        */
        callbackList.clear();
    }

    public interface ResponseCallback{
        public void onSuccess(String url, ResponseBody response);
    }
}
