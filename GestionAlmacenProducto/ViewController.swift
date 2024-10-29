import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pickerCategoria: UIPickerView!
    @IBOutlet weak var botonFiltrar: UIButton!
    
    var productos: [Producto] = []
    var categorias: [String] = ["Todos"]
    var categoriaSeleccionada: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        pickerCategoria.delegate = self
        pickerCategoria.dataSource = self
        pickerCategoria.isHidden = true
        obtenerProductos()
        obtenerCategorias()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        obtenerProductos()
        tableView.reloadData()
    }
    
    @IBAction func btnFiltrarTapped(_ sender: Any) {
        pickerCategoria.isHidden.toggle() // Alternar la visibilidad del picker
    }
    
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
        categoriaSeleccionada = categorias[row]
        buscarProducto(texto: searchBar.text ?? "", categoria: categoriaSeleccionada) // Buscar por categoría seleccionada
        pickerCategoria.isHidden = true // Ocultar el picker después de seleccionar
        tableView.reloadData() // Actualizar la tabla
    }
    
    func obtenerCategorias() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Producto> = Producto.fetchRequest()
        
        do {
            let productos = try contexto.fetch(request)
            let categoriasSet = Set(productos.compactMap { $0.categoria }) // Obtener categorías únicas
            categorias = Array(categoriasSet).sorted() // Convertir a Array y ordenar
            pickerCategoria.reloadAllComponents() // Recargar el picker
        } catch {
            print("Error al obtener categorías: \(error)")
        }
    }

    func obtenerProductos() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            productos = try contexto.fetch(Producto.fetchRequest())
        } catch {
            print("Error al obtener productos: \(error)")
        }
    }

    func buscarProducto(texto: String, categoria: String?) {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Producto> = Producto.fetchRequest()

        var predicates: [NSPredicate] = []
        
        if !texto.isEmpty {
            predicates.append(NSPredicate(format: "nombre CONTAINS[cd] %@", texto))
        }

        if let categoria = categoria, !categoria.isEmpty {
            predicates.append(NSPredicate(format: "categoria == %@", categoria))
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        do {
            productos = try contexto.fetch(request)
        } catch {
            print("Error al buscar productos: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let producto = productos[indexPath.row]
        cell.textLabel?.text = "\(producto.nombre ?? "Sin Nombre") - \(producto.categoria ?? "Sin Categoria")"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productoSeleccionado = productos[indexPath.row]
        performSegue(withIdentifier: "SegueDetail", sender: productoSeleccionado)
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        buscarProducto(texto: searchText, categoria: categoriaSeleccionada)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueAgregarEditar" {
            if let addVC = segue.destination as? AddViewController {
                if let productoAEditar = sender as? Producto {
                    addVC.productoAEditar = productoAEditar
                }
            }
        } else if segue.identifier == "SegueDetail" {
            if let detailVC = segue.destination as? DetailViewController {
                if let productoDetalle = sender as? Producto {
                    detailVC.producto = productoDetalle
                }
            }
        }
    }
}
