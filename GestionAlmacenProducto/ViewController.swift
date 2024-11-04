import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var fondoPickerView: UIView!
    @IBOutlet weak var categoriaPickerView: UIPickerView!

    var productos: [Producto] = []
    var categorias: [String] = ["Todos", "Abarrote", "Electrónica", "Ropa", "Hogar"]
    var categoriaSeleccionada: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        categoriaPickerView.delegate = self
        categoriaPickerView.dataSource = self
        obtenerProductos()

        // Ocultar el fondo y el UIPickerView al cargar la vista
        fondoPickerView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        obtenerProductos()
        tableView.reloadData()
    }

    // Método para mostrar el UIPickerView de categoría
    @IBAction func seleccionarCategoriaTapped(_ sender: UIButton) {
        fondoPickerView.isHidden = false
        if let categoriaSeleccionada = categoriaSeleccionada,
           let index = categorias.firstIndex(of: categoriaSeleccionada) {
            categoriaPickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }

    // Delegado de UIPickerView para configurar las filas
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorias.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorias[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Actualizar la categoría seleccionada y ocultar el UIPickerView
        categoriaSeleccionada = categorias[row] == "Todos" ? nil : categorias[row]
        fondoPickerView.isHidden = true
        buscarProducto(texto: searchBar.text ?? "")
    }

    func obtenerProductos() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            productos = try contexto.fetch(Producto.fetchRequest())
        } catch {
            print("Error al obtener productos: \(error)")
        }
    }

    func buscarProducto(texto: String) {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Producto> = Producto.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if !texto.isEmpty {
            let textoPredicate = NSPredicate(format: "nombre CONTAINS[cd] %@", texto)
            predicates.append(textoPredicate)
        }
        
        if let categoria = categoriaSeleccionada {
            let categoriaPredicate = NSPredicate(format: "categoria == %@", categoria)
            predicates.append(categoriaPredicate)
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            productos = try contexto.fetch(request)
        } catch {
            print("Error al buscar productos: \(error)")
        }
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        buscarProducto(texto: searchText)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let producto = productos[indexPath.row]

        // Configurar el texto de la celda
        cell.textLabel?.text = producto.nombre ?? "Sin Nombre"
        cell.detailTextLabel?.text = producto.categoria ?? "Sin Categoría"

        // Cargar la imagen desde imageData en Core Data
        if let imageData = producto.imageData {
            cell.imageView?.image = UIImage(data: imageData)
        } else {
            cell.imageView?.image = UIImage(named: "placeholder") // Imagen por defecto si no hay imagen
        }

        // Ajuste del tamaño de la imagen
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 8
        cell.imageView?.clipsToBounds = true

        // Configura el tamaño de la imagen en la celda
        let itemSize = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect(origin: .zero, size: itemSize)
        cell.imageView?.image?.draw(in: imageRect)
        cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return cell
    }

    func eliminarProducto(at indexPath: IndexPath) {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let productoAEliminar = productos[indexPath.row]
        contexto.delete(productoAEliminar)

        do {
            try contexto.save()
            productos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Error al eliminar el producto: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editarAccion = UIContextualAction(style: .normal, title: "Editar") { (action, view, completionHandler) in
            let productoAEditar = self.productos[indexPath.row]
            self.performSegue(withIdentifier: "SegueAgregarEditar", sender: productoAEditar)
            completionHandler(true)
        }
        editarAccion.backgroundColor = UIColor.blue

        let eliminarAccion = UIContextualAction(style: .destructive, title: "Eliminar") { (action, view, completionHandler) in
            self.eliminarProducto(at: indexPath)
            completionHandler(true)
        }

        let configuracion = UISwipeActionsConfiguration(actions: [eliminarAccion, editarAccion])
        return configuracion
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productoSeleccionado = productos[indexPath.row]
        performSegue(withIdentifier: "SegueDetail", sender: productoSeleccionado)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueAgregarEditar" {
            if let addVC = segue.destination as? AddViewController {
                if let productoAEditar = sender as? Producto {
                    addVC.productoAEditar = productoAEditar
                }
            }
        } else if segue.identifier == "SegueDetail" {
            if let detailVC = segue.destination as? DetailViewController,
               let indexPath = tableView.indexPathForSelectedRow {
                detailVC.producto = productos[indexPath.row]
            }
        }
    }
}
