import UIKit
import CoreData

class ProductosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var productoTableView: UITableView! // Conexión del IBOutlet con el TableView
    @IBOutlet weak var txtCantidadTotalProductos: UITextField!
    @IBOutlet weak var txtTotalDineroProductos: UITextField!
    
    var categorias: [Categoria] = [] // Array para las categorías
    var productosPorCategoria: [Categoria: [Producto]] = [:] // Productos agrupados por categoría
    
    var cantidadTotal: Int = 0
    var totalDinero: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuramos el delegado y el datasource para el TableView
        productoTableView.delegate = self
        productoTableView.dataSource = self

        // Cargar las categorías y productos desde CoreData
        obtenerCategoriasYProductos()

        // Deshabilitar la edición de los UITextFields para cantidad y total
        txtCantidadTotalProductos.isUserInteractionEnabled = false
        txtTotalDineroProductos.isUserInteractionEnabled = false
    }

    // Función para obtener categorías y productos desde Core Data
    func obtenerCategoriasYProductos() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Obtener categorías
        let fetchRequest: NSFetchRequest<Categoria> = Categoria.fetchRequest()

        do {
            categorias = try contexto.fetch(fetchRequest)
            
            // Agrupar los productos por categoría
            for categoria in categorias {
                let productos = categoria.productos?.allObjects as! [Producto]
                productosPorCategoria[categoria] = productos
            }

            // Llamamos a la función para calcular totales
            calcularTotales()

            productoTableView.reloadData() // Recargamos el TableView después de obtener los datos
        } catch {
            print("Error al obtener categorías y productos: \(error)")
        }
    }

    // Función para calcular la cantidad total y el dinero total
    func calcularTotales() {
        cantidadTotal = 0
        totalDinero = 0.0
        
        // Recorremos las categorías y los productos, sumando las cantidades y los totales.
        for categoria in categorias {
            if let productos = productosPorCategoria[categoria] {
                for producto in productos {
                    // Aquí ya no necesitas "if let" ya que "precio" y "cantidad" son valores no opcionales
                    if producto.precio > 0, producto.cantidad > 0 {
                        cantidadTotal += Int(producto.cantidad)  // Sumamos las cantidades
                        totalDinero += Double(producto.cantidad) * producto.precio  // Sumamos el total (precio * cantidad)
                    }
                }
            }
        }

        // Actualizar los UITextFields con los totales calculados
        txtCantidadTotalProductos.text = "\(cantidadTotal)"
        
        // Formatear el total de dinero como moneda
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let totalFormateado = formatter.string(from: NSNumber(value: totalDinero)) {
            txtTotalDineroProductos.text = totalFormateado
        }
    }



    // MARK: - Métodos de TableView

    // Número de secciones (una por cada categoría)
    func numberOfSections(in tableView: UITableView) -> Int {
        return categorias.count
    }

    // Número de filas por sección (número de productos en esa categoría)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoria = categorias[section]
        return productosPorCategoria[categoria]?.count ?? 0
    }

    // Título del encabezado de cada sección (nombre de la categoría)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let categoria = categorias[section]
        return categoria.nombre
    }

    // Configuración de cada celda para mostrar el nombre, precio, cantidad y total del producto
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoria = categorias[indexPath.section]
        let producto = productosPorCategoria[categoria]?[indexPath.row]

        // Usamos una celda personalizada o estándar
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductoCell", for: indexPath)

        // Configuramos el texto de la celda (nombre del producto)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.textLabel?.text = producto?.nombre ?? "Sin Nombre"
        
        // Crear el texto con saltos de línea para precio, cantidad y total
        var detalleTexto = ""
        
        if let precio = producto?.precio, let cantidad = producto?.cantidad {
            let total = Double(precio) * Double(cantidad)
            
            // Formateamos el texto para mostrar precio, cantidad y total en varias líneas
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            let precioFormateado = formatter.string(from: NSNumber(value: precio)) ?? "$\(precio)"
            let totalFormateado = formatter.string(from: NSNumber(value: total)) ?? "$\(total)"
            
            detalleTexto = "Precio: \(precioFormateado)\nCantidad: \(cantidad)\nTotal: \(totalFormateado)"
        } else {
            detalleTexto = "Sin datos de precio o cantidad"
        }
        
        // Establecer el texto en el detailTextLabel o una nueva label
        // Usamos detailTextLabel para mostrar varios detalles
        cell.detailTextLabel?.numberOfLines = 0  // Permite varias líneas
        cell.detailTextLabel?.text = detalleTexto
        
        // Cargar la imagen del producto si existe
        if let imageData = producto?.imageData, let image = UIImage(data: imageData) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(named: "placeholder")
        }

        // Configuramos la imagen para que tenga un buen estilo
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 8
        cell.imageView?.clipsToBounds = true

        return cell
    }

    // Método para gestionar la selección de un producto
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Obtener el producto seleccionado
        let categoria = categorias[indexPath.section]
        let productoSeleccionado = productosPorCategoria[categoria]?[indexPath.row]
        
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
