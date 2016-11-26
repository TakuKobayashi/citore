package kobayashi.taku.com.citore;

import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.support.annotation.Nullable;
import android.util.Log;
import android.widget.Toast;

public class VoiceRecordService extends Service{
	private final class ServiceHandler extends Handler {
		// メッセージ送付先指定のハンドラを作成
		public ServiceHandler(Looper looper) {
			super(looper);
		}

		public void handleMessage(Message msg) {
			// サービスオブジェクトでの２重処理防止。
			synchronized (this) {
				try {
					// トースト発行。ただし、handleMessageが終わるまで実行されない。
					Toast.makeText(getApplicationContext(),
							"handleMessage wait 5000ms" + msg.arg1,
							Toast.LENGTH_SHORT).show();
					wait(5000);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			Toast.makeText(getApplicationContext(), "handleMessage end",
					Toast.LENGTH_SHORT).show();
			Log.d(Config.TAG, "end::::::");
			// 処理後、サービスの停止。
			stopSelf(msg.arg1);
		}
	}

	private Looper mServiceLooper;
	private ServiceHandler mServiceHandler;

	public void onCreate() {
		// ハンドラスレッドを生成。
		// （ここで、ルーパー（メッセージディスパッチャーみたいなもの）
		// が作成されるようです。）
		HandlerThread thread = new HandlerThread("ServiceStartArguments",
				android.os.Process.THREAD_PRIORITY_BACKGROUND);
		thread.start();
		// ハンドラスレッドからメッセージルーパー取得
		mServiceLooper = thread.getLooper();
		// サービスハンドラを生成
		mServiceHandler = new ServiceHandler(mServiceLooper);
		Log.d(Config.TAG, "create");
	}

	public int onStartCommand(Intent intent, int flags, int startId) {
		Log.d(Config.TAG, "start");
		Toast.makeText(this, "service starting", Toast.LENGTH_SHORT).show();
		// サービスハンドラのglobal message poolから再利用可能なメッセージを取得
		// なければ新たにメッセージのインスタンス化してメッセージ返却
		Message msg = mServiceHandler.obtainMessage();
		msg.arg1 = startId;
		// ハンドラに対し、メッセージ送付
		mServiceHandler.sendMessage(msg);
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
		Log.d(Config.TAG, "destroy");
		Toast.makeText(this, "service done", Toast.LENGTH_SHORT).show();
	}
}