import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var productos: [Producto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        obtenerProductos()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        obtenerProductos()
        tableView.reloadData()
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

        if !texto.isEmpty {
            request.predicate = NSPredicate(format: "nombre CONTAINS[cd] %@", texto)
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
        buscarProducto(texto: searchText)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueAgregarEditar" {
            if let addVC = segue.destination as? AddViewController {
                if let productoAEditar = sender as? Producto {
                    addVC.productoAEditar = productoAEditar
                }
            }
        }
    }
}
