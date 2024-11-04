import UIKit

class ProductoTableViewCell: UITableViewCell {

    @IBOutlet weak var productoImageView: UIImageView!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var categoriaLabel: UILabel!
    @IBOutlet weak var edadLabel: UILabel!
    @IBOutlet weak var distanciaLabel: UILabel!
    @IBOutlet weak var favoritoIcon: UIImageView! // O UIButton si quieres interactividad

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configuraciones adicionales
        productoImageView.layer.cornerRadius = 8
        productoImageView.clipsToBounds = true
        productoImageView.contentMode = .scaleAspectFill
    }
}
