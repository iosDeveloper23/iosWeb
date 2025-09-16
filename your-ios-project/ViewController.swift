//
//  WebViewController.swift
//  MobileBank
//
//  Created by Farrukh Khamidov on 16/09/25.
//

import UIKit
import WebKit
import AuthenticationServices

class WebViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return self.view.window ?? ASPresentationAnchor()
  }
  
  private var webView: WKWebView!
  private var authSession: ASWebAuthenticationSession?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupWebView()
    setupNavigationBar()
    loadWebPage()
  }
  
  private func setupWebView() {
    let configuration = WKWebViewConfiguration()
    
    let pref = WKWebpagePreferences()
    pref.preferredContentMode = .mobile
    
    configuration.defaultWebpagePreferences = pref
    // Use default data store for password autofill support
    configuration.websiteDataStore = WKWebsiteDataStore.default()
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    
    webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = self
    webView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(webView)
    
    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupNavigationBar() {
    title = "WebView"
    navigationController?.navigationBar.prefersLargeTitles = false
    
    // Add refresh button and auth button
    let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWebView))
    let authButton = UIBarButtonItem(title: "Auth Login", style: .plain, target: self, action: #selector(startAuthSession))
    
    navigationItem.rightBarButtonItems = [refreshButton, authButton]
  }
  
  private func loadWebPage() {
    // Load the main page in WKWebView
    guard let url = URL(string: "https://iosdeveloper23.github.io") else { return }
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  @objc private func startAuthSession() {
    
    SecAddSharedWebCredential(
      "iosdeveloper23.github.io" as CFString,
      "admin" as CFString,
      "password" as CFString
    ) { error in
      DispatchQueue.main.async {
        if let error = error {
          print("Failed to save credential: \(error)")
        } else {
          print("Credential saved to Passwords app successfully")
          // Show success message to user
          self.showAlert(title: "Success", message: "Password saved to your Passwords app")
        }
      }
    }
  }
  
  func showAlert(title: String, message: String) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         present(alert, animated: true)
     }
//    guard #available(iOS 12.0, *) else {
//      print("ASWebAuthenticationSession is not available on this iOS version")
//      return
//    }
//    
//    let url = URL(string: "https://iosdeveloper23.github.io")!
//    let callbackScheme = "iosdeveloper23app"
//    
//    authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { [weak self] callbackURL, error in
//      DispatchQueue.main.async {
//        if let error = error {
//          print("Authentication error: \(error.localizedDescription)")
//          if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
//            print("User canceled authentication")
//          }
//        } else if let callbackURL = callbackURL {
//          print("Authentication successful with callback: \(callbackURL)")
//          self?.handleAuthenticationSuccess(callbackURL: callbackURL)
//        }
//      }
//    }
//    
//    authSession?.presentationContextProvider = self
//    authSession?.prefersEphemeralWebBrowserSession = false
//    authSession?.start()
//  }
  
  private func handleAuthenticationSuccess(callbackURL: URL) {
    print("Handling authentication success: \(callbackURL)")
    
    if let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
       let queryItems = components.queryItems {
      for item in queryItems {
        print("Parameter: \(item.name) = \(item.value ?? "")")
      }
    }
    
    loadWebPage()
  }
  
  @objc private func refreshWebView() {
    webView.reload()
  }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    // Show loading indicator if needed
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    // Hide loading indicator if needed
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("WebView failed to load: \(error.localizedDescription)")
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let url = navigationAction.request.url,
       url.path.contains("login") || url.path.contains("auth") {
      // Optionally redirect login attempts to ASWebAuthenticationSession
      // startAuthSession()
      // decisionHandler(.cancel)
      // return
    }
    
    decisionHandler(.allow)
  }
}
