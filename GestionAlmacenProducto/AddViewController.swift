import UIKit
import CoreData

class AddViewController: UIViewController {

    @IBOutlet weak var txtCod: UITextField!
    @IBOutlet weak var txtNom: UITextField!
    @IBOutlet weak var txtCat: UITextField!
    @IBOutlet weak var txtCant: UITextField!
    @IBOutlet weak var txtPrecio: UITextField!

    var productoAEditar: Producto?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Si hay un producto a editar, cargar sus datos
        if let producto = productoAEditar {
            txtCod.text = producto.codigo
            txtNom.text = producto.nombre
            txtCat.text = producto.categoria
            txtCant.text = String(producto.cantidad)
            txtPrecio.text = String(producto.precio)
        }
    }

    @IBAction func btnGuardar(_ sender: Any) {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let producto = productoAEditar {
            // Actualizar producto existente
            producto.codigo = txtCod.text
            producto.nombre = txtNom.text
            producto.categoria = txtCat.text
            producto.cantidad = Int16(txtCant.text ?? "0") ?? 0
            producto.precio = Double(txtPrecio.text ?? "0") ?? 0.0
        } else {
            // Crear nuevo producto
            let nuevoProducto = Producto(context: contexto)
            nuevoProducto.codigo = txtCod.text
            nuevoProducto.nombre = txtNom.text
            nuevoProducto.categoria = txtCat.text
            nuevoProducto.cantidad = Int16(txtCant.text ?? "0") ?? 0
            nuevoProducto.precio = Double(txtPrecio.text ?? "0") ?? 0.0
        }

        do {
            try contexto.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error al guardar el producto: \(error)")
        }
    }

    @IBAction func btnCancelar(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
