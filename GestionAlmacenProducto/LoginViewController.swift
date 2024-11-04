import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    @IBOutlet weak var gradientView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnLogin(_ sender: Any) {
        guard let usuario = txtUsuario.text, !usuario.isEmpty,
              let contrasena = txtContrasena.text, !contrasena.isEmpty else {
            showAlert(message: "Por favor, complete todos los campos.")
            return
        }

        if usuario == "admin" && contrasena == "Pollito123" || usuario == "jhon" && contrasena == "1234" {
            // Las credenciales son correctas se realizara la transicion
        } else {
            showAlert(message: "Usuario o contraseña incorrectos.")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor.systemCyan.cgColor,
            UIColor.systemGreen.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 2)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

}
