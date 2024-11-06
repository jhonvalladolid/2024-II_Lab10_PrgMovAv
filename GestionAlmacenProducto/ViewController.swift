import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var productoTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var productos: [Producto] = [] // Array para los productos
    var productosFiltrados: [Producto] = [] // Array para productos filtrados (por nombre)

    override func viewDidLoad() {
        super.viewDidLoad()
        productoTableView.delegate = self
        productoTableView.dataSource = self
        searchBar.delegate = self  // Asignar el delegado para la barra de búsqueda

        obtenerProductos()  // Llamar a la función para obtener los productos desde Core Data
    }

    // Recargar los datos cuando la vista aparezca (después de agregar o editar)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        obtenerProductos() // Llamamos a la función para obtener los productos
    }

    // Función para obtener productos desde Core Data
    func obtenerProductos() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()

        // Ejecutar la búsqueda si hay texto en la barra de búsqueda
        if let textoBusqueda = searchBar.text, !textoBusqueda.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "nombre CONTAINS[cd] %@", textoBusqueda)
        }

        do {
            productos = try contexto.fetch(fetchRequest)
            productosFiltrados = productos  // Usamos productos filtrados para la tabla
            productoTableView.reloadData() // Recargamos la tabla después de obtener los productos
        } catch {
            print("Error al obtener productos: \(error)")
        }
    }

    // Función para manejar la barra de búsqueda
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        obtenerProductos()  // Llamamos nuevamente a obtener productos con el texto filtrado
    }

    // Función del delegate de UISearchBar para que al hacer "return" se cierre el teclado
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // Función del delegate de UISearchBar para que se limpie la búsqueda cuando el texto está vacío
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        obtenerProductos()  // Recargamos todos los productos sin filtro
    }

    // Función que devuelve el número de filas en la tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productosFiltrados.count
    }

    // Función que configura la celda para mostrar el nombre del producto y la imagen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductoCell", for: indexPath)
        let producto = productosFiltrados[indexPath.row]

        cell.textLabel?.text = producto.nombre ?? "Sin Nombre"

        if let imageData = producto.imageData, let image = UIImage(data: imageData) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(named: "placeholder")
        }

        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 8
        cell.imageView?.clipsToBounds = true

        return cell
    }

    // Método para gestionar la selección de un producto
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Obtener el producto seleccionado
        let productoSeleccionado = productosFiltrados[indexPath.row]
        
        // Realizamos el segue hacia el DetailViewController
        performSegue(withIdentifier: "SegueDetail", sender: productoSeleccionado)
    }

    // Preparar para el segue de detalle (modal)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueDetail" {
            if let detailVC = segue.destination as? DetailViewController {
                if let productoSeleccionado = sender as? Producto {
                    // Pasamos el producto seleccionado al controlador de detalles
                    detailVC.producto = productoSeleccionado
                }
            }
        }
    }
}
