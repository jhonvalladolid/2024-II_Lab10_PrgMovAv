import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var productoTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var productos: [Producto] = []
    var productosFiltrados: [Producto] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        productoTableView.delegate = self
        productoTableView.dataSource = self
        searchBar.delegate = self

        obtenerProductos()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        obtenerProductos()
    }

    func obtenerProductos() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()

        if let textoBusqueda = searchBar.text, !textoBusqueda.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "nombre CONTAINS[cd] %@", textoBusqueda)
        }

        do {
            productos = try contexto.fetch(fetchRequest)
            productosFiltrados = productos
            productoTableView.reloadData()
        } catch {
            print("Error al obtener productos: \(error)")
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        obtenerProductos()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        obtenerProductos()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productosFiltrados.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ProductoCell")
        let producto = productosFiltrados[indexPath.row]

        // Configuración del texto principal y subtítulo para la celda
        cell.textLabel?.text = producto.nombre ?? "Sin Nombre"
        cell.detailTextLabel?.text = producto.categorias?.nombre ?? "Sin Categoría"

        // Cargar la imagen desde imageData en Core Data
        if let imageData = producto.imageData {
            cell.imageView?.image = UIImage(data: imageData)
        } else {
            cell.imageView?.image = UIImage(named: "placeholder")
        }

        // Ajuste del tamaño de la imagen
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 8
        cell.imageView?.clipsToBounds = true

        // Redimensionar la imagen a 50x50
        let itemSize = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect(origin: .zero, size: itemSize)
        cell.imageView?.image?.draw(in: imageRect)
        cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editarAccion = UIContextualAction(style: .normal, title: "Editar") { (action, view, completionHandler) in
            let productoAEditar = self.productosFiltrados[indexPath.row]
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

    func eliminarProducto(at indexPath: IndexPath) {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let productoAEliminar = productosFiltrados[indexPath.row]
        contexto.delete(productoAEliminar)

        do {
            try contexto.save()
            productosFiltrados.remove(at: indexPath.row)
            productoTableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            print("Error al eliminar el producto: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productoSeleccionado = productosFiltrados[indexPath.row]
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
               let productoSeleccionado = sender as? Producto {
                detailVC.producto = productoSeleccionado
            }
        }
    }
}
