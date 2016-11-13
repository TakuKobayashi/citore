package jp.co.sharp.sample.simple.util;


import jp.co.sharp.android.voiceui.VoiceUIListener;
import jp.co.sharp.android.voiceui.VoiceUIManager;
import jp.co.sharp.android.voiceui.VoiceUIVariable;
import jp.co.sharp.sample.simple.customize.ScenarioDefinitions;

import android.os.RemoteException;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * VoiceUIManager関連のUtilityクラス.
 */
public class VoiceUIManagerUtil {
    public static final String TAG = VoiceUIManagerUtil.class.getSimpleName();

    //static クラスとして使用する.
    private VoiceUIManagerUtil(){}

    /**
     * {@link VoiceUIManager#registerVoiceUIListener} のラッパー関数
     * @param vm VoiceUIManagerインスタンス
     * @param listener {@link VoiceUIListener}
     * @return 関数の実行結果
     * @see VoiceUIManager#registerVoiceUIListener(VoiceUIListener)
     */
    static public int registerVoiceUIListener (VoiceUIManager vm, VoiceUIListener listener) {
        int result = VoiceUIManager.VOICEUI_ERROR;
        if (vm != null) {
            try {
                result = vm.registerVoiceUIListener(listener);
            } catch (RemoteException e) {
                Log.e(TAG, "Failed registerVoiceUIListener.[" + e.getMessage() + "]");
            }
        }
        return result;
    }

    /**
     * {@link VoiceUIManager#unregisterVoiceUIListener} のラッパー関数
     * @param vm VoiceUIManagerインスタンス
     * @param listener {@link VoiceUIListener}
     * @return 関数の実行結果
     * @see VoiceUIManager#unregisterVoiceUIListener(VoiceUIListener)
     */
    public static int unregisterVoiceUIListener (VoiceUIManager vm, VoiceUIListener listener) {
        int result = VoiceUIManager.VOICEUI_ERROR;
        if (vm != null) {
            try {
                result = vm.unregisterVoiceUIListener(listener);
            } catch (RemoteException e) {
                Log.e(TAG, "Failed unregisterVoiceUIListener.[" + e.getMessage() + "]");
            }
        }
        return result;
    }

    /**
     * sceneを有効にする.
     * <br>
     * 指定のsceneを1つだけ有効化するのみであり、複数指定も発話指定もしない.
     *
     * @param vm VoiceUIManagerインスタンス.
     *            {@code null}の場合は {@code VoiceUIManager.VOICEUI_ERROR} を返す.
     * @param scene 有効にするscene名.
     *              {@code null}や空文字の場合は {@code VoiceUIManager.VOICEUI_ERROR} を返す.
     * @return updateAppInfoの実行結果
     */
    static public int enableScene(VoiceUIManager vm, final String scene) {
        int result = VoiceUIManager.VOICEUI_ERROR;
        // 引数チェック.
        if (vm == null || scene == null || "".equals(scene)) {
            return result;
        }
        VoiceUIVariable variable = new VoiceUIVariable(ScenarioDefinitions.TAG_SCENE, VoiceUIVariable.VariableType.STRING);
        variable.setStringValue(scene);
        variable.setExtraInfo(VoiceUIManager.SCENE_ENABLE);
        ArrayList<VoiceUIVariable> listVariables = new ArrayList<>();
        listVariables.add(variable);
        try {
            result = vm.updateAppInfo(listVariables);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed updateAppInfo.[" + e.getMessage() + "]");
        }
        return result;
    }

    /**
     * sceneを無効にする.
     * <br>
     * 指定のsceneを1つだけ無効にするのみであり、複数指定も発話指定もしない.
     *
     * @param vm VoiceUIManagerインスタンス.
     *            {@code null}の場合は {@code VoiceUIManager.VOICEUI_ERROR} を返す.
     * @param scene 有効にするscene名.
     *              {@code null}や空文字の場合は {@code VoiceUIManager.VOICEUI_ERROR} を返す.
     * @return updateAppInfoの実行結果
     */
    static public int disableScene(VoiceUIManager vm, final String scene) {
        int result = VoiceUIManager.VOICEUI_ERROR;
        // 引数チェック.
        if (vm == null || scene == null || "".equals(scene)) {
            return result;
        }
        VoiceUIVariable variable = new VoiceUIVariable(ScenarioDefinitions.TAG_SCENE, VoiceUIVariable.VariableType.STRING);
        variable.setStringValue(scene);
        variable.setExtraInfo(VoiceUIManager.SCENE_DISABLE);
        ArrayList<VoiceUIVariable> listVariables = new ArrayList<VoiceUIVariable>();
        listVariables.add(variable);
        try {
            result = vm.updateAppInfo(listVariables);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed updateAppInfo.[" + e.getMessage() + "]");
        }
        return result;
    }

    /**
     * {@link VoiceUIManager#updateAppInfo}と {@link VoiceUIManager#updateAppInfoAndSpeech} のラッパー関数
     * @param vm VoiceUIManagerインスタンス
     * @param listVariables variableリスト
     * @param speech 発話するかどうか
     * @return 関数の実行結果
     */
    static public int updateAppInfo(VoiceUIManager vm, final List<VoiceUIVariable> listVariables, final boolean speech) {
        int result = VoiceUIManager.VOICEUI_ERROR;
        // 引数チェック.
        if (vm == null || listVariables == null) {
            return result;
        }
        try {
            if (speech) {
                result = vm.updateAppInfoAndSpeech(listVariables);
            } else {
                result = vm.updateAppInfo(listVariables);
            }
        } catch (RemoteException e) {
            if (speech) {
                Log.e(TAG, "Failed updateAppInfoAndSpeech.[" + e.getMessage() + "]");
            } else {
                Log.e(TAG, "Failed updateAppInfo.[" + e.getMessage() + "]");
            }
        }
        return result;
    }

    /**
     * {@link VoiceUIManager#stopSpeech} のラッパー関数.
     * <br>
     * RemoteExceptionをthrowせずにerrorログを出力する.
     */
    static public void stopSpeech() {
        try {
            VoiceUIManager.stopSpeech();
        } catch (RemoteException e) {
            Log.e(TAG, "Failed StopSpeech.[" + e.getMessage() + "]");
        }
    }
}
