#include <jni.h>
#include <string.h>
#include <android/log.h>
#include <algorithm>
#include "FFT4g.h"
#include <vector>
#include <math.h>

using namespace std;

extern "C" {
JNIEXPORT void JNICALL Java_kobayashi_taku_com_citore_NativeHelper_FFTrdft(
        JNIEnv *env, jobject obj, jint size, jint isgn, jdoubleArray fft_data) {
    jdoubleArray fft_doubles = env->NewDoubleArray(size);
    jdouble *darr = env->GetDoubleArrayElements(fft_data, 0);
    FFT4g *fft4g = new FFT4g(sizeof(fft_doubles));
    fft4g->rdft(isgn, darr);
    env->ReleaseDoubleArrayElements(fft_doubles, darr, 0);
}

}