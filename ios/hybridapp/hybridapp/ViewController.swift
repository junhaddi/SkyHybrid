import UIKit
import WebKit
import StoreKit
import UnityAds

class ViewController: UIViewController,
    WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,
    SKProductsRequestDelegate,
    UnityAdsDelegate {
    
    var webView: WKWebView!
    
    var products: [SKProduct]!
    
    var showUnityAdsCallbackName: String!
    
    var registeredPushKey: String!
    var registerPushKeyHandlerName: String!
    
    override func loadView() {
        let webViewConfig = WKWebViewConfiguration()
        let webViewContentController = WKUserContentController()
        webViewConfig.userContentController = webViewContentController
        
        webViewContentController.add(self, name: "init")
        
        // 푸시 관련
        webViewContentController.add(self, name: "removePushKey")
        webViewContentController.add(self, name: "generateNewPushKey")
        
        // 결제 관련
        webViewContentController.add(self, name: "initPurchaseService")
        webViewContentController.add(self, name: "purchase")
        webViewContentController.add(self, name: "consumePurchase")
        
        // 유니티 광고 관련
        webViewContentController.add(self, name: "showUnityAd")
        
        webView = WKWebView(frame: .zero, configuration: webViewConfig)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default) {  _ in
            completionHandler(true)
        })
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        })
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if (message.name == "init") {
            let data = message.body as! [String:AnyObject]
            
            if (registeredPushKey == nil) {
                registerPushKeyHandlerName = data["registerPushKeyHandlerName"] as! String
            } else {
                webView.evaluateJavaScript(data["registerPushKeyHandlerName"] as! String + "('" + registeredPushKey + "')")
            }
            
            // 유니티 광고 초기화
            UnityAds.initialize(data["unityAdsGameId"] as! String, delegate: self, testMode: data["isDevMode"] as! Bool)
            
            // 결제 초기화
            let request = SKProductsRequest(productIdentifiers: Set(data["productIds"] as! [String]))
            request.delegate = self
            request.start()
        }
        
        if (message.name == "initPurchaseService") {
            
        }
        
        if (message.name == "purchase") {
            let data = message.body as! [String:AnyObject]
            
            let productId = data["productId"] as! String
            let errorHandlerName = data["errorHandlerName"] as! String
            let cancelHandlerName = data["cancelHandlerName"] as! String
            let callbackName = data["callbackName"] as! String
            
            if (products == nil) {
                //TOOD:
            } else {
                for product in products {
                    if product.productIdentifier == productId {
                        SKPaymentQueue.default().add(SKPayment(product: product))
                    }
                }
            }
        }
        
        if (message.name == "consumePurchase") {
            
        }
        
        if (message.name == "showUnityAd") {
            let data = message.body as! [String:AnyObject]
            
            let errorHandlerName = data["errorHandlerName"] as! String
            showUnityAdsCallbackName = data["callbackName"] as! String
            
            if (UnityAds.isReady() == true) {
                UnityAds.show(self, placementId: "rewardedVideo")
            } else {
                webView.evaluateJavaScript(errorHandlerName + "()")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (UIApplication.shared.delegate as! AppDelegate).viewController = self
        
        // 화면 계속 켜진 상태로 유지
        UIApplication.shared.isIdleTimerDisabled = true
        
        // index.html 로딩
        let baseURL = Bundle.main.url(forResource: "www", withExtension: nil)!
        let indexURL = baseURL.appendingPathComponent("index.html")
        let htmlString = try? String(contentsOf: indexURL, encoding: String.Encoding.utf8)
        webView.loadHTMLString(htmlString!, baseURL: baseURL)
    }
    
    func registerPushKey(_ pushKey: String) {
        if (registerPushKeyHandlerName == nil) {
            registeredPushKey = pushKey
        } else {
            webView.evaluateJavaScript(registerPushKeyHandlerName + "(" + pushKey + ")")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products;
    }
    
    func unityAdsReady(_ placementId: String) { }
    
    func unityAdsDidStart(_ placementId: String) { }
    
    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) { }
    
    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
        webView.evaluateJavaScript(showUnityAdsCallbackName + "()")
    }
}