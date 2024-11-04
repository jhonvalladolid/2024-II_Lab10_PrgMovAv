import UIKit
import CoreData

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var txtCod: UITextField!
    @IBOutlet weak var txtNom: UITextField!
    @IBOutlet weak var txtCat: UITextField!
    @IBOutlet weak var txtCant: UITextField!
    @IBOutlet weak var txtPrecio: UITextField!
    @IBOutlet weak var productoImageView: UIImageView! // UIImageView para mostrar la imagen seleccionada

    var productoAEditar: Producto?
    var imagenSeleccionada: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Si hay un producto a editar, cargar sus datos
        if let producto = productoAEditar {
            txtCod.text = producto.codigo
            txtNom.text = producto.nombre
            txtCat.text = producto.categoria
            txtCant.text = String(producto.cantidad)
            txtPrecio.text = String(producto.precio)
            
            // Cargar la imagen del producto a editar, si existe
            if let imageData = producto.imageData {
                productoImageView.image = UIImage(data: imageData)
            }
        }

        // Agregar UITapGestureRecognizer al UIImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seleccionarImagen))
        productoImageView.isUserInteractionEnabled = true
        productoImageView.addGestureRecognizer(tapGesture)
    }

    @objc func seleccionarImagen() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate: Manejar la selección de imagen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagen = info[.originalImage] as? UIImage {
            imagenSeleccionada = imagen
            productoImageView.image = imagen
        }
        dismiss(animated: true, completion: nil)
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
            
            // Guardar la imagen seleccionada en Core Data
            if let imagen = imagenSeleccionada {
                producto.imageData = imagen.jpegData(compressionQuality: 0.8)
            }
        } else {
            // Crear nuevo producto
            let nuevoProducto = Producto(context: contexto)
            nuevoProducto.codigo = txtCod.text
            nuevoProducto.nombre = txtNom.text
            nuevoProducto.categoria = txtCat.text
            nuevoProducto.cantidad = Int16(txtCant.text ?? "0") ?? 0
            nuevoProducto.precio = Double(txtPrecio.text ?? "0") ?? 0.0
            
            // Guardar la imagen seleccionada en Core Data
            if let imagen = imagenSeleccionada {
                nuevoProducto.imageData = imagen.jpegData(compressionQuality: 0.8)
            }
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
