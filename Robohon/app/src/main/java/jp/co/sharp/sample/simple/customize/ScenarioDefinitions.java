package jp.co.sharp.sample.simple.customize;

/**
 * シナリオファイルで使用する定数の定義クラス.<br>
 * <p/>
 * <p>
 * controlタグのtargetにはPackage名を設定すること<br>
 * scene、memory_p(長期記憶の変数名)、resolve variable(アプリ変数解決の変数名)、accostのwordはPackage名を含むこと<br>
 * </p>
 */
public class ScenarioDefinitions {

    /**
     * sceneタグを指定する文字列
     */
    public static final String TAG_SCENE = "scene";
    /**
     * accostタグを指定する文字列
     */
    public static final String TAG_ACCOST = "accost";
    /**
     * target属性を指定する文字列
     */
    public static final String ATTR_TARGET = "target";
    /**
     * function属性を指定する文字列
     */
    public static final String ATTR_FUNCTION = "function";
    /**
     * memory_pを指定するタグ
     */
    public static final String TAG_MEMORY_PERMANENT = "memory_p:";
    /**
     * Package名.
     */
    protected static final String PACKAGE = "jp.co.sharp.sample.simple";
    /**
     * シナリオ共通: controlタグで指定するターゲット名.
     */
    public static final String TARGET = PACKAGE;
    /**
     * scene名: アプリ共通シーン
     */
    public static final String SCENE_COMMON = PACKAGE + ".scene_common";
    /**
     * function：アプリ終了を通知する.
     */
    public static final String FUNC_END_APP = "end_app";
    /**
     * function：発話内容を通知する.
     */
    public static final String FUNC_RECOG_TALK = "recog_talk";
    /**
     * accost名：accostテスト発話実行.
     */
    public static final String ACC_ACCOST =  ScenarioDefinitions.PACKAGE + ".accost.t1";
    /**
     * accost名：resolveテスト発話実行.
     */
    public static final String ACC_RESOLVE =  ScenarioDefinitions.PACKAGE + ".variable.t1";
    /**
     * accost名：get_memorypの発話実行.
     */
    public static final String ACC_GET_MEMORYP =  ScenarioDefinitions.PACKAGE + ".get_memoryp.t1";
    /**
     * accost名：アプリ終了発話実行.
     */
    public static final String ACC_END_APP = ScenarioDefinitions.PACKAGE + ".app_end.t2";
    /**
     * resolve variable：アプリで変数解決する値.
     */
    public static final String RESOLVE_JAVA_VALUE = ScenarioDefinitions.PACKAGE + ":java_side_value";
    /**
     * data key：シナリオ起動時情報1.
     */
    public static final String KEY_TEST_1 = "key_test1";
    /**
     * data key：シナリオ起動時情報2.
     */
    public static final String KEY_TEST_2 = "key_test2";
    /**
     * data key：大語彙認識文言.
     */
    public static final String KEY_LVCSR_BASIC = "Lvcsr_Basic";
    /**
     * memory_p：時.
     */
    public static final String MEM_P_HOUR = ScenarioDefinitions.TAG_MEMORY_PERMANENT + ScenarioDefinitions.PACKAGE + ".hour";
    /**
     * memory_p：分.
     * */
    public static final String MEM_P_MINUTE = ScenarioDefinitions.TAG_MEMORY_PERMANENT + ScenarioDefinitions.PACKAGE + ".minute";
    /**
     * static クラスとして使用する.
     */
    private ScenarioDefinitions() {
    }

}
