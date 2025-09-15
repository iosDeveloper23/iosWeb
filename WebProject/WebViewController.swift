import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupNavigationBar()
        loadWebPage()
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        
        // Configure non-persistent data store
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        // Additional privacy configurations
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        
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
        
        // Add refresh button
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWebView))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    private func loadWebPage() {
        guard let url = URL(string: "https://iosdeveloper23.github.io/testWeb") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
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
}
