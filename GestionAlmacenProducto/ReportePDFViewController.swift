import UIKit

class ReportePDFViewController: UIViewController {
    
    var pdfURL: URL?
    @IBOutlet weak var webView: UIWebView!  // Usando UIWebView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asegurarnos de que el webView esté conectado
        if let url = pdfURL {
            let request = URLRequest(url: url)
            webView.loadRequest(request)  // Cargar el PDF en el UIWebView
        }
    }
    
    func mostrarPDF(pdfURL: URL) {
        self.pdfURL = pdfURL
    }
}
