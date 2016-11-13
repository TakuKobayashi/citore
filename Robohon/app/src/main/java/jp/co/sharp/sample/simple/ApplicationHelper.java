package jp.co.sharp.sample.simple;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.hardware.Camera;
import android.os.Build;
import android.os.Bundle;
import android.util.Base64;
import android.view.Surface;
import android.webkit.WebView;
import android.widget.ImageView;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Map;
import java.util.Set;

public class ApplicationHelper {

	//ImageViewを使用したときのメモリリーク対策
	public static void releaseImageView(ImageView imageView){
		if (imageView != null) {
			BitmapDrawable bitmapDrawable = (BitmapDrawable)(imageView.getDrawable());
			if (bitmapDrawable != null) {
				bitmapDrawable.setCallback(null);
			}
			imageView.setImageBitmap(null);
		}
	}

	//WebViewを使用したときのメモリリーク対策
	public static void releaseWebView(WebView webview){
		webview.stopLoading();
		webview.setWebChromeClient(null);
		webview.setWebViewClient(null);
		webview.destroy();
		webview = null;
	}

	public static int getCameraDisplayOrientation(Activity act, int nCameraID){
		if(Build.VERSION.SDK_INT >= 9){
			Camera.CameraInfo info = new Camera.CameraInfo();
			Camera.getCameraInfo(nCameraID, info);
			int rotation = act.getWindowManager().getDefaultDisplay().getRotation();
			int degrees = 0;
			switch (rotation) {
				//portate:縦向き
				case Surface.ROTATION_0: degrees = 0; break;
				//landscape:横向き
				case Surface.ROTATION_90: degrees = 90; break;
				case Surface.ROTATION_180: degrees = 180; break;
				case Surface.ROTATION_270: degrees = 270; break;
			}
			int result;
			//Camera.CameraInfo.CAMERA_FACING_FRONT:アウトカメラ
			//Camera.CameraInfo.CAMERA_FACING_BACK:インカメラ

			if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
				result = (info.orientation + degrees) % 360;
				result = (360 - result) % 360;  // compensate the mirror
			} else {  // back-facing
				result = (info.orientation - degrees + 360) % 360;
			}
			return result;
		}
		return 90;
	}

	public static boolean checkCameraHardware(Context context) {
		if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA)) {
			// this device has a camera
			return true;
		} else {
			// no camera on this device
			return false;
		}
	}

	public static String makeUrlParams(Bundle params){
		Set<String> keys = params.keySet();
		ArrayList<String> paramList = new ArrayList<String>();
		for (String key : keys) {
			paramList.add(key + "=" + params.get(key).toString());
		}
		return ApplicationHelper.join(paramList, "&");
	}

	public static String makeUrlParams(Map<String, Object> params){
		Set<String> keys = params.keySet();
		ArrayList<String> paramList = new ArrayList<String>();
		for(Map.Entry<String, Object> e : params.entrySet()) {
			paramList.add(e.getKey() + "=" + e.getValue().toString());
		}
		return ApplicationHelper.join(paramList, "&");
	}

	public static String join(String[] list, String with) {
		StringBuffer buf = new StringBuffer();
		for (int i = 0; i < list.length; i++) {
			if (i != 0) { buf.append(with);}
			buf.append(list[i]);
		}
		return buf.toString();
	}

	public static String join(ArrayList<String> list, String with) {
		StringBuffer buf = new StringBuffer();
		for (int i = 0; i < list.size(); i++) {
			if (i != 0) { buf.append(with);}
			buf.append(list.get(i));
		}
		return buf.toString();
	}

	public static ArrayList<String> getSettingPermissions(Context context){
		ArrayList<String> list = new ArrayList<String>();
		PackageInfo packageInfo = null;
		try {
			packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), PackageManager.GET_PERMISSIONS);
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		}
		if(packageInfo == null || packageInfo.requestedPermissions == null) return list;

		for(String permission : packageInfo.requestedPermissions){
			list.add(permission);
		}
		return list;
	}

	public static String loadTextFromAsset(Context con, String fileName) {

		AssetManager mngr = con.getAssets();
		//rawフォルダにあるファイルのリソースでの読み込み
		String str;
		try {
			InputStream is = mngr.open(fileName);
			str = ApplicationHelper.Is2String(is);
		} catch (IOException e) {
			str = "";
		}
		return str;
	}

	public static String Is2String(InputStream in) throws IOException {
		//入力されたテキストデータ(InputStream,これはbyteデータ)を文字列(String)に変換

		StringBuffer out = new StringBuffer();
		byte[] b = new byte[4096];
		//保持しているStringデータ全てをStringBufferに入れる
		for (int n; (n = in.read(b)) != -1;) {
			out.append(new String(b, 0, n));
		}
		return out.toString();
	}

	public static String encodeToJPEGbase64(Bitmap image)
	{
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		image.compress(Bitmap.CompressFormat.JPEG, 100, baos);
		byte[] b = baos.toByteArray();
		String imageEncoded = Base64.encodeToString(b, Base64.DEFAULT);
		return imageEncoded;
	}

	public static <T> T getClassByField(Object object, Class<T> targetClass) {
		Field[] declaredFields = object.getClass().getDeclaredFields();

		for (Field field : declaredFields) {
			if (field.getType() == targetClass) {
				field.setAccessible(true);
				try {
					T target = (T) field.get(object);
					return target;
				} catch (IllegalAccessException e) {
					e.printStackTrace();
				}
				break;
			}
		}
		return null;
	}
}