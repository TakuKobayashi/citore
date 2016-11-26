package kobayashi.taku.com.citore;

import android.app.Service;
import android.content.Intent;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.Toast;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class VoiceRecordService extends Service{
	private Thread mLoopThread;
	private AudioRecord mAudioRecord = null;
	private boolean mIsRecording = false;
	private static final int SAMPLING_RATE = 44100;
	private byte[] mRecordingBuffer;
	private static final int FFT_SIZE = 4096;
	// デシベルベースラインの設定
	private double dB_baseline = Math.pow(2, 15) * FFT_SIZE * Math.sqrt(2);
	// 分解能の計算
	private double resol = ((SAMPLING_RATE / (double) FFT_SIZE));

	public void onCreate() {
		mRecordingBuffer = new byte[AudioRecord.getMinBufferSize(SAMPLING_RATE,
				AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT) * 2];
		mAudioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLING_RATE,
				AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT,
				mRecordingBuffer.length);
		// ハンドラスレッドを生成。
		// （ここで、ルーパー（メッセージディスパッチャーみたいなもの）
		// が作成されるようです。）
		mLoopThread = new Thread() {
			@Override
			public void run() {
				RecordingSound();
			}
		};
		mLoopThread.start();
		Log.d(Config.TAG, "create");
	}

	private void RecordingSound(){
		mIsRecording = true;
		while (mIsRecording) {
			// 録音データ読み込み
			int read = mAudioRecord.read(mRecordingBuffer, 0, mRecordingBuffer.length);
			if (read < 0) {
				throw new IllegalStateException();
			}
			ByteBuffer bf = ByteBuffer.wrap(mRecordingBuffer);
			bf.order(ByteOrder.LITTLE_ENDIAN);
			short[] s = new short[(int) mRecordingBuffer.length];
			for (int i = bf.position(); i < bf.capacity() / 2; i++) {
				s[i] = bf.getShort();
			}

			double[] FFTdata = new double[FFT_SIZE];
			for (int i = 0; i < FFT_SIZE; i++) {
				FFTdata[i] = (double) s[i];
			}
			NativeHelper.FFTrdft(FFT_SIZE, 1, FFTdata);
			// デシベルの計算
			double[] dbfs = new double[FFT_SIZE / 2];
			double max_db = -120d;
			int max_i = 0;
			for (int i = 0; i < FFT_SIZE; i += 2) {
				dbfs[i / 2] = (int) (20 * Math.log10(Math.sqrt(Math.pow(FFTdata[i], 2)
						+ Math.pow(FFTdata[i + 1], 2)) / dB_baseline));
				if (max_db < dbfs[i / 2]) {
					max_db = dbfs[i / 2];
					max_i = i / 2;
				}
			}
			//音量が最大の周波数と，その音量を表示
			Log.d("fft","周波数："+ resol * max_i+" [Hz] 音量：" +  max_db+" [dB]");
		}
		mAudioRecord.stop();
		mAudioRecord.release();
	}

	public int onStartCommand(Intent intent, int flags, int startId) {
		Log.d(Config.TAG, "start");
		// サービスハンドラのglobal message poolから再利用可能なメッセージを取得
		// なければ新たにメッセージのインスタンス化してメッセージ返却
		// ハンドラに対し、メッセージ送付
		// START_STICKY は明示的に起動され、明示的に停止されるサービスが使う。
		// START_NOT_STICKYはonStartCommand() から戻った後、サービスを強制終了した場合、
		// ペンディングインテントが存在しない限りサービスが再開されないようにするものです 。
		// START_REDELIVER_INTENTはonStartCommand() から戻った後、サービスを強制終了した場合、
		// 最後にサービスに配信された最後のインテントにてサービス再開させるもの。
		// （世の中のアプリがやたら常駐する理由はこれか！）
		return START_STICKY;
	}

	public IBinder onBind(Intent intent) {
		Log.d(Config.TAG, "bind");
		return null;
	}

	public void onDestroy() {
		mIsRecording = false;
		Log.d(Config.TAG, "destroy");
		Toast.makeText(this, "service done", Toast.LENGTH_SHORT).show();
	}
}