package jp.co.sharp.sample.simple.common;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/**
 * 音声UIのシナリオ登録要求レシーバークラス.
 *
 * <p>シナリオ登録自体は自前のサービスで行う</p>
 */
public class RequestScenarioReceiver extends BroadcastReceiver {
    private static final String TAG = RequestScenarioReceiver.class.getSimpleName();

    /** シナリオ登録Action. */
    private static final String ACTION_REQUEST_SCENARIO = "jp.co.sharp.android.voiceui.REQUEST_SCENARIO";

    @Override
    public void onReceive(Context context, Intent intent) {
        if(ACTION_REQUEST_SCENARIO.equals(intent.getAction())) {
            //シナリオ登録要求の場合
            Log.d(TAG, "onReceive-S:" + intent.getAction());
            Intent baseIntent = new Intent();
            RegisterScenarioService.start(context, baseIntent, RegisterScenarioService.CMD_REQUEST_SCENARIO);
            Log.d(TAG, "onReceive-E:" + intent.getAction());
        } else {
            Log.e(TAG, "onReceive Unknown action" + intent.getAction());
        }
    }
}
