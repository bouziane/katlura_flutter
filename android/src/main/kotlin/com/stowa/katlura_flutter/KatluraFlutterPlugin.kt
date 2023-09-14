package com.stowa.katlura_flutter

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.annotation.NonNull
import com.kaltura.tvplayer.KalturaOvpPlayer
import com.kaltura.tvplayer.KalturaPlayer
import com.kaltura.tvplayer.OVPMediaOptions
import com.kaltura.tvplayer.PlayerInitOptions
import io.flutter.embedding.engine.plugins.FlutterPlugin

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** KatluraFlutterPlugin */
class KatluraFlutterPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel



  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "katlura_flutter")
    channel.setMethodCallHandler(this)

    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "katlura_player",
      KatluraPlayerViewFactory(flutterPluginBinding.binaryMessenger)
    )
  }
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}


class KatluraPlayerViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
    val map = args as? Map<*, *>
    val videoId = map?.get("videoId") as? String ?: "default_id" // Fournissez un ID par défaut si nécessaire

    return KatluraPlayerView(context, messenger, viewId, videoId)
  }
}

class KatluraPlayerView(context: Context?, messenger: BinaryMessenger, id: Int, private val videoId: String) : PlatformView,
  MethodChannel.MethodCallHandler {
  private val channel = MethodChannel(messenger, "katlura_flutter_$id")
  private val player: KalturaPlayer
  companion object {
    private const val TAG = "KatluraPlayerView"
    public const val OVP_SERVER_URL = "https://cdnapisec.kaltura.com"
    public const val PARTNER_ID = 5540632
  }

  init {
//    player = PlayKitManager.loadPlayer(context, null);
    KalturaOvpPlayer.initialize(context!!, PARTNER_ID, OVP_SERVER_URL)

    val playerInitOptions = PlayerInitOptions(PARTNER_ID) //player config/behavior
    player = KalturaOvpPlayer.create(context!!, playerInitOptions)
    player.setPlayerView(FrameLayout.LayoutParams.MATCH_PARENT,FrameLayout.LayoutParams.MATCH_PARENT)

    val ovpMediaOptions = buildOvpMediaOptions()
    player.loadMedia(ovpMediaOptions
    ) { p0, p1, p2 -> Log.d(TAG, "onEntryLoadComplete:$p0 $p1 $p2") }

    channel.setMethodCallHandler { call, result ->
      when (call.method) {
        "playVideo" -> {
          player?.play()
          result.success(null)
        }
        "pauseVideo" -> {
          player?.pause()
          result.success(null)
        }
        else -> result.notImplemented()
      }}
  }

  override fun getView(): View {
    return player.playerView
  }

  override fun dispose() {
    // Dispose of any resources if necessary
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "playVideo" -> {
        player.play()
        result.success(null)
      }
      "pauseVideo" -> {
        player.pause()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }
  private fun buildOvpMediaOptions(): OVPMediaOptions {
    return   OVPMediaOptions(videoId)
  }
}

