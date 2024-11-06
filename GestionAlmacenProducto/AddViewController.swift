import UIKit
import CoreData

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var txtCod: UITextField!
    @IBOutlet weak var txtNom: UITextField!
    @IBOutlet weak var txtCat: UITextField! // Campo para seleccionar categoría
    @IBOutlet weak var txtCant: UITextField!
    @IBOutlet weak var txtPrecio: UITextField!
    @IBOutlet weak var productoImageView: UIImageView!
    
    var productoAEditar: Producto?
    var imagenSeleccionada: UIImage?
    var categorias: [Categoria] = [] // Array para almacenar las categorías de Core Data
    var categoriaSeleccionada: Categoria? // Variable para la categoría seleccionada
    let categoriaPickerView = UIPickerView() // UIPickerView para selección de categoría

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración del UIPickerView
        categoriaPickerView.delegate = self
        categoriaPickerView.dataSource = self
        txtCat.inputView = categoriaPickerView // Establecer UIPickerView como inputView de txtCat
        
        // Cargar categorías desde Core Data
        cargarCategorias()

        // Cargar datos del producto si estamos en modo de edición
        if let producto = productoAEditar {
            txtCod.text = producto.codigo
            txtNom.text = producto.nombre
            txtCant.text = String(producto.cantidad)
            txtPrecio.text = String(producto.precio)
            
            if let imageData = producto.imageData {
                productoImageView.image = UIImage(data: imageData)
            }
            
            // Si el producto tiene una categoría, mostrarla en txtCat
            if let categoria = producto.categorias {
                categoriaSeleccionada = categoria
                txtCat.text = categoria.nombre // Mostrar nombre de la categoría en el campo
            }
        }

        configurarImagen()
    }
    
    func configurarImagen() {
        productoImageView.contentMode = .scaleAspectFit
        productoImageView.layer.cornerRadius = 10
        productoImageView.clipsToBounds = true
        productoImageView.layer.borderWidth = 1
        productoImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(seleccionarImagen))
        productoImageView.isUserInteractionEnabled = true
        productoImageView.addGestureRecognizer(tapGesture)
    }

    // Cargar las categorías desde Core Data
    func cargarCategorias() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Categoria> = Categoria.fetchRequest()
        
        do {
            categorias = try contexto.fetch(fetchRequest)
        } catch {
            print("Error al cargar categorías: \(error)")
        }
    }
    
    // MARK: - UIPickerView Delegate and DataSource Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorias.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorias[row].nombre
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Al seleccionar una categoría, asignarla y mostrar el nombre en txtCat
        categoriaSeleccionada = categorias[row]
        txtCat.text = categorias[row].nombre
    }

    // Método para seleccionar imagen
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

    // Método para validar los campos y mostrar una alerta si hay algún campo vacío
    func validarCampos() -> Bool {
        if txtCod.text?.isEmpty ?? true {
            mostrarAlerta(mensaje: "Por favor, ingrese el código.")
            return false
        }
        
        if txtNom.text?.isEmpty ?? true {
            mostrarAlerta(mensaje: "Por favor, ingrese el nombre.")
            return false
        }
        
        if txtCat.text?.isEmpty ?? true {
            mostrarAlerta(mensaje: "Por favor, seleccione una categoría.")
            return false
        }
        
        if txtCant.text?.isEmpty ?? true {
            mostrarAlerta(mensaje: "Por favor, ingrese la cantidad.")
            return false
        }
        
        if txtPrecio.text?.isEmpty ?? true {
            mostrarAlerta(mensaje: "Por favor, ingrese el precio.")
            return false
        }
        
        return true
    }

    // Método para mostrar una alerta
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }

    @IBAction func btnGuardar(_ sender: Any) {
        // Validar los campos antes de guardar
        guard validarCampos() else { return }
        
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Crear o actualizar el producto
        let producto = productoAEditar ?? Producto(context: contexto)
        
        producto.codigo = txtCod.text
        producto.nombre = txtNom.text
        producto.cantidad = Int16(txtCant.text ?? "0") ?? 0
        producto.precio = Double(txtPrecio.text ?? "0") ?? 0.0
        producto.categorias = categoriaSeleccionada // Asignar la categoría seleccionada al producto

        if let imagen = imagenSeleccionada {
            producto.imageData = imagen.jpegData(compressionQuality: 0.8)
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
