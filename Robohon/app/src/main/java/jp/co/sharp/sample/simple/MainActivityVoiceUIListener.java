package jp.co.sharp.sample.simple;

import android.content.Context;
import android.util.Log;

import java.util.List;

import jp.co.sharp.android.voiceui.VoiceUIListener;
import jp.co.sharp.android.voiceui.VoiceUIVariable;
import jp.co.sharp.sample.simple.customize.ScenarioDefinitions;
import jp.co.sharp.sample.simple.util.VoiceUIVariableUtil;


/**
 * 音声UIからの通知を処理する.
 * Callbackの中では重い処理をしないこと.
 */
public class MainActivityVoiceUIListener implements VoiceUIListener {
    private static final String TAG = MainActivityVoiceUIListener.class.getSimpleName();

    private MainActivityScenarioCallback mCallback;

    /**
     * Activity側でのCallback実装チェック（実装してないと例外発生）.
     */
    public MainActivityVoiceUIListener(Context context) {
        super();
        try {
            mCallback = (MainActivityScenarioCallback) context;
        } catch (ClassCastException e) {
            throw new ClassCastException(context.toString() + " must implement " + TAG);
        }
    }

    @Override
    public void onVoiceUIEvent(List<VoiceUIVariable> variables) {
        //controlタグからの通知(シナリオ側にcontrolタグのあるActionが開始されると呼び出される).
        //発話と同時にアプリ側で処理を実行したい場合はこちらを使う.
        Log.v(TAG, "onVoiceUIEvent");
    }

    @Override
    public void onVoiceUIActionEnd(List<VoiceUIVariable> variables) {
        //Actionの完了通知(シナリオ側にcontrolタグを書いたActionが完了すると呼び出される).
        //発話が終わった後でアプリ側の処理を実行したい場合はこちらを使う.
        Log.v(TAG, "onVoiceUIActionEnd");
        if (VoiceUIVariableUtil.isTarget(variables, ScenarioDefinitions.TARGET)) {
            mCallback.onExecCommand(VoiceUIVariableUtil.getVariableData(variables, ScenarioDefinitions.ATTR_FUNCTION), variables);
        }
    }

    @Override
    public void onVoiceUIResolveVariable(List<VoiceUIVariable> variables) {
        //アプリ側での変数解決用コールバック(シナリオ側にパッケージ名をつけた変数を書いておくと呼び出される).
        Log.v(TAG, "onVoiceUIResolveVariable");
        for (VoiceUIVariable variable : variables) {
            String key = variable.getName();
            Log.d(TAG, "onVoiceUIResolveVariable: " + key + ":" + variable.getStringValue());
            if (ScenarioDefinitions.RESOLVE_JAVA_VALUE.equals(key)) {
                variable.setStringValue("java");
            }
        }
    }

    @Override
    public void onVoiceUIActionCancelled(List<VoiceUIVariable> variables) {
        //priorityが高いシナリオに割り込まれた場合の通知.
        Log.v(TAG, "onVoiceUIActionCancelled");
        if (VoiceUIVariableUtil.isTargetFuncution(variables, ScenarioDefinitions.TARGET,
            ScenarioDefinitions.FUNC_END_APP)) {
            mCallback.onExecCommand(ScenarioDefinitions.FUNC_END_APP, variables);
        }
    }

    @Override
    public void onVoiceUIRejection(VoiceUIVariable variable) {
        //priority負けなどで発話が棄却された場合のコールバック.
        Log.v(TAG, "onVoiceUIRejection");
        if (ScenarioDefinitions.ACC_END_APP.equals(variable.getStringValue())) {
            mCallback.onExecCommand(ScenarioDefinitions.FUNC_END_APP, null);
        }
    }

    @Override
    public void onVoiceUISchedule(int i) {
        //処理不要(リマインダーアプリ以外は使われない).
    }

    /**
     * Activityへの通知用IFクラス.
     */
    public static interface MainActivityScenarioCallback {
        /**
         * 実行されたcontrolの通知.
         *
         * @param function 実行された操作コマンド種別.
         */
        public void onExecCommand(String function, List<VoiceUIVariable> variables);
    }

}
