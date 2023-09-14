import Flutter
import UIKit
import PlayKit
import PlayKitUtils
import PlayKitProviders

public class KatluraFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {

    let viewFactory = KatluraPlayerViewFactory(registrar: registrar)
    registrar.register(viewFactory, withId: "katlura_player_ios")

    let channel = FlutterMethodChannel(name: "katlura_flutter", binaryMessenger: registrar.messenger())
    let instance = KatluraFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }



  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
        
    
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

public class KatluraPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
  let registrar: FlutterPluginRegistrar
  

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let videoId = (args as? [String: Any])?["videoId"] as? String ?? "default_video_id"
        return KatluraPlayerView(frame: frame, viewId: viewId, videoId: videoId, registrar: registrar)
    }
}

public class KatluraPlayerView: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    
    let registrar: FlutterPluginRegistrar
    var player: Player?
    var playerContainer: PlayerView?
    var channel: FlutterMethodChannel?
    let videoId: String



    init(frame: CGRect, viewId: Int64, videoId: String, registrar: FlutterPluginRegistrar) {
        self.frame = frame
        self.viewId = viewId
        self.videoId = videoId
        self.registrar = registrar
        self.channel = FlutterMethodChannel(name: "katlura_flutter_\(viewId)", binaryMessenger: registrar.messenger())

        super.init()
    
        self.channel?.setMethodCallHandler { [weak self] (call, result) in
                    switch call.method {
                    case "playVideo":
                        self?.player?.play()
                        result(nil)
                    case "pauseVideo":
                        self?.player?.pause()
                        result(nil)
                    default:
                        result(FlutterMethodNotImplemented)
                    }
                }

        self.player = PlayKitManager.shared.loadPlayer(pluginConfig: nil)
        
        self.loadMedia()
        self.preparePlayer()
    }

    public func view() -> UIView {
        return self.playerContainer ?? UIView()
    }
   
    func loadMedia() {
          let sessionProvider = SimpleSessionProvider(serverURL: "https://cdnapisec.kaltura.com", partnerId: Int64(5540632), ks: nil)
          
          let mediaProvider: OVPMediaProvider = OVPMediaProvider(sessionProvider)
          
        mediaProvider.entryId = self.videoId
          
          mediaProvider.loadMedia { (mediaEntry, error) in
              if let me = mediaEntry, error == nil {
                  
                  let mediaConfig = MediaConfig(mediaEntry: me, startTime: 0.0)
                  
                  if let player = self.player {
                      
                      player.prepare(mediaConfig)
                      
                  }
              }
          }
      }
    
    private func preparePlayer() {
        self.playerContainer = PlayerView(frame: frame)
        self.player?.view = self.playerContainer
        
        
        

        self.player?.addObserver(self, event: PlayerEvent.stateChanged, block: { event in
            print("Player state changed: \(event.newState)")

         
            // switch event.newState {
            //     case PlayerState.ready, PlayerState.error: self.activityIndicator.stopAnimating()
            //     case PlayerState.buffering: self.activityIndicator.startAnimating()
            //     default: break
            // }
        })

    }
}



