import Flutter
import UIKit
import TalsecRuntime

/// A Flutter plugin that interacts with the Talsec runtime library, handles method calls and provides event streams.
public class SwiftFreeraspPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    /// The event processor used to handle and dispatch events.
    private let eventProcessor = EventProcessor()
    
    /// The singleton instance of `SwiftTalsecPlugin`.
    static let instance = SwiftFreeraspPlugin()
    
    var initialchecksDone = false
    var initialChecksDoneResult: FlutterResult? = nil
    
    private override init() {}
    
    /// Registers this plugin with the given `FlutterPluginRegistrar`.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        
        let eventChannel = FlutterEventChannel(name: "talsec.app/freerasp/events", binaryMessenger: messenger)
        eventChannel.setStreamHandler(instance)
        
        //Channels init
        let methodChannel : FlutterMethodChannel = FlutterMethodChannel(name: "talsec.app/freerasp/methods", binaryMessenger: messenger)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
    }
    
    /// Handles a method call from Flutter.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` object representing the method call.
    ///   - result: The `FlutterResult` object to be returned to the caller.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
        switch call.method {
        case "start":
            guard let args = call.arguments as? Dictionary<String, String>
            else {
                result(FlutterError(code: "talsec-failure", message: "Unexpected arguments", details: nil))
                return
            }
            start(args: args, result: result)
            return
        case "getBiometricsState":
            getBiometricsState(result: result)
            return
        case "awaitInitialChecksDone":
            awaitInitialChecksDone(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func awaitInitialChecksDone(result: @escaping FlutterResult) {
        if (initialchecksDone) {
            result(true)
            return
        }
        initialChecksDoneResult = result
    }
    
    private func getBiometricsState(result: @escaping FlutterResult) {
        result(BiometryService.hasBiometry())
    }
    
    /// Runs Talsec with given configuration
    ///
    /// - Parameters:
    ///   - args: The arguments received from Flutter which contains configuration
    ///   - result: The `FlutterResult` object to be returned to the caller.
    private func start(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        guard let json = args["config"],
              let data = json.data(using: .utf8),
              let flutterConfig = try? JSONDecoder().decode(FlutterTalsecConfig.self, from: data)
        else {
            result(FlutterError(code: "configuration-exception", message: "Unable to decode configuration", details: nil))
            return
        }
        
        Talsec.start(config: flutterConfig.toNativeConfig())

        // Flutter expects *some* result to be returned even if it's void
        result(nil)
    }
    
    /// Attaches a FlutterEventSink to the EventProcessor and processes any detectedThreats in the queue.
    ///
    /// - Parameters:
    /// - arguments: Unused
    /// - events: The FlutterEventSink to be attached to the EventProcessor.
    /// - Returns: Always returns nil.
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventProcessor.attachSink(sink: events)
        return nil
    }
    
    // Detaches the current FlutterEventSink from the EventProcessor.
    ///
    /// - Parameters:
    /// - arguments: Unused
    /// - Returns: Always returns nil.
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventProcessor.detachSink()
        return nil
    }
    
    /// Processes a submitted SecurityThreat event.
    ///
    /// - Parameters:
    /// - submittedEvent: The SecurityThreat event to be processed.
    public func submitEvent(_ submittedEvent: SecurityThreat) {
        if (submittedEvent == SecurityThreat.passcodeChange){
            return
        }
        eventProcessor.processEvent(submittedEvent)
    }
    
    public func submitEvent(_ submittedEvent: String) {
        eventProcessor.processEvent(submittedEvent)
    }
}
