import UIKit
import CoreData

class AgregarCategoriaViewController: UIViewController {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtDescripcion: UITextField!
    
    var categoria: Categoria? // Propiedad para la categoría que se va a editar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let categoria = categoria {
            txtNombre.text = categoria.nombre
            txtDescripcion.text = categoria.descripcion
        }
    }

    @IBAction func btnGuardar(_ sender: Any) {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let categoria = categoria {
            // Editar la categoría existente
            categoria.nombre = txtNombre.text
            categoria.descripcion = txtDescripcion.text
        } else {
            // Crear una nueva categoría
            let nuevaCategoria = Categoria(context: contexto)
            nuevaCategoria.nombre = txtNombre.text
            nuevaCategoria.descripcion = txtDescripcion.text
        }
        
        do {
            try contexto.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error al guardar la categoría: \(error)")
        }
    }
}
