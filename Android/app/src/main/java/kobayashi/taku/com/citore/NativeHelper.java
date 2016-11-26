package kobayashi.taku.com.citore;

public class NativeHelper {
    static {
        System.loadLibrary("jni_sample");
    }

    public static native void FFTrdft(int size, int isgn, double[] fft_data);
}
