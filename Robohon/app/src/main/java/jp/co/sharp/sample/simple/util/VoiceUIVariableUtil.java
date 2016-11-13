package jp.co.sharp.sample.simple.util;


import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import jp.co.sharp.android.voiceui.VoiceUIManager;
import jp.co.sharp.android.voiceui.VoiceUIVariable;
import jp.co.sharp.android.voiceui.VoiceUIVariable.VariableType;
import jp.co.sharp.sample.simple.customize.ScenarioDefinitions;


/**
 * VoiceUIVariable関連のUtilityクラス.
 */
public final class VoiceUIVariableUtil {

    //static クラスとして使用する.
    private VoiceUIVariableUtil(){}


    /**
     * 指定したtargetが含まれるか判定する.
     *
     * @param variableList variableリスト
     * @param target target属性のvalue値
     * @return {@code true} : 含む<br>
     *          {@code false} : 含まない
     */
    public static boolean isTarget(final List<VoiceUIVariable> variableList, final String target) {
        boolean result = false;
        for (int i = 0; i < variableList.size(); i++) {
            if (getVariableData(variableList, ScenarioDefinitions.ATTR_TARGET).equals(target)) {
                result = true;
                break;
            }
        }
        return result;
    }

    /**
     * 指定したtargetとfunctionが含まれるか判定する.
     *
     * @param variableList variableリスト
     * @param target target属性のvalue値
     * @param function function属性のvalue値
     * @return {@code true} : 含む<br>
     *          {@code false} : 含まない
     */
    public static boolean isTargetFuncution(final List<VoiceUIVariable> variableList, final String target, final String function) {
        boolean result = false;
        for (int i = 0; i < variableList.size(); i++) {
            if (getVariableData(variableList, ScenarioDefinitions.ATTR_TARGET).equals(target)) {
                if(getVariableData(variableList, ScenarioDefinitions.ATTR_FUNCTION).equals(function)) {
                    result = true;
                    break;
                }
            }
        }
        return result;
    }

    /**
     *
     * 変数nameにStringデータvalueを格納して音声UIに登録する.
     *
     * @param vm VoiceUIManagerインスタンス
     * @param name データの名前
     * @param value データ
     * @return 関数の実行結果
     */
    public static int setVariableData(VoiceUIManager vm, final String name, final String value){
        ArrayList<VoiceUIVariable> list = new ArrayList<VoiceUIVariable>();
        VoiceUIVariable tmp;
        int result;
        tmp = new VoiceUIVariable(name, VariableType.STRING);//STRING型のname変数をセット
        tmp.setStringValue(value); //tmp内のname変数に、値valueをセット
        list.add(tmp);
        result = VoiceUIManagerUtil.updateAppInfo(vm,list,false);
        return result;
    }

    /**
     * variableのリストから指定した名前のvariableに格納されているStringデータを取得する.
     *
     * @param variableList variableリスト
     * @param name 取得するvariableの名前
     * @return 指定したvariableに格納されているString型のvalue値.<br>
     *          {@code name}と一致するものがなくてもvariable空文字を返す.<br>
     *          {@code null}は返さない.
     */
    public static String getVariableData(final List<VoiceUIVariable> variableList, final String name) {
        String result = "";
        int index = getListIndex(variableList, name);
        if (index != -1) {
            result = variableList.get(index).getStringValue();
        }
        return result;
    }

    /**
     * variableのリストから指定した名前のvariableが格納されているindex値を取得する.
     *
     * @param variableList variableリスト
     * @param name 取得するvariableの名前
     * @return {@code index} : 格納されているindex値<br>
     *          {@code -1} : 指定した名前が存在しない
     */
    public static int getListIndex(final List<VoiceUIVariable> variableList, final String name) {
        int index = -1;
        int tmp = 0;
        Iterator<VoiceUIVariable> it = variableList.iterator();
        while (it.hasNext()) {
            VoiceUIVariable variable = it.next();
            if (variable.getName().equals(name)) {
                index = tmp;
                break;
            }
            tmp++;
        }
        return index;
    }

    public static class VoiceUIVariableListHelper {
        ArrayList<VoiceUIVariable> mList = null;

        public VoiceUIVariableListHelper() {
            mList = new ArrayList<>();
        }

        /**
         * 作成したリストを返す
         * @return VoiceUIVariable のリスト
         */
        public ArrayList<VoiceUIVariable> getVariableList() {
            return mList;
        }

        /**
         * 使用するシナリオのaccostを指定する.
         *
         * @param accost 指定するaccostタブのvalue
         * @return VoiceUIVariableListHelperオブジェクト
         */
        public VoiceUIVariableListHelper addAccost(final String accost) {
            VoiceUIVariable variable = new VoiceUIVariable(ScenarioDefinitions.TAG_ACCOST, VariableType.STRING);
            variable.setStringValue(accost);
            mList.add(variable);
            return this;
        }

        /**
         * 使用するシナリオのsceneを指定する.
         *
         * @param scene 指定するsceneタブのvalue
         * @param extraInfo 指定するsceneタブのvalue
         * @return VoiceUIVariableListHelperオブジェクト
         */
        public VoiceUIVariableListHelper addScene(final String scene, final String extraInfo) {
            VoiceUIVariable variable = new VoiceUIVariable(ScenarioDefinitions.TAG_SCENE, VariableType.STRING);
            variable.setStringValue(scene);
            variable.setExtraInfo(extraInfo);
            mList.add(variable);
            return this;
        }

        /**
         * String型の値を追加する.
         *
         * @param key 追加する値の名前
         * @param value 追加する文字列
         * @return VoiceUIVariableListHelperオブジェクト
         */
        public VoiceUIVariableListHelper addStringValue(final String key, final String value) {
            VoiceUIVariable variable = new VoiceUIVariable(key, VariableType.STRING);
            variable.setStringValue(value);
            mList.add(variable);
            return this;
        }

        /**
         * float型の値を追加する.
         *
         * @param key 追加する値の名前
         * @param value 追加する数値
         * @return VoiceUIVariableListHelperオブジェクト
         */
        public VoiceUIVariableListHelper addFloatValue(final String key, final float value) {
            VoiceUIVariable variable = new VoiceUIVariable(key, VariableType.FLOAT);
            variable.setFloatValue(value);
            mList.add(variable);
            return this;
        }

        /**
         * boolean型の値を追加する.
         *
         * @param key 追加する値の名前
         * @param value 追加する真偽値
         * @return VoiceUIVariableListHelperオブジェクト
         */
        public VoiceUIVariableListHelper addBooleanValue(final String key, final boolean value) {
            VoiceUIVariable variable = new VoiceUIVariable(key, VariableType.BOOLEAN);
            variable.setBooleanValue(value);
            mList.add(variable);
            return this;
        }
    }
}

