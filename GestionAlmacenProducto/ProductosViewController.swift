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

    // Acción del botón para generar el reporte en PDF
    @IBAction func generarReportePDF(_ sender: Any) {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595.2, height: 841.8))  // A4 size
        
        let data = pdfRenderer.pdfData { (context) in
            context.beginPage()
            
            // Título del reporte
            let titleFont = UIFont.boldSystemFont(ofSize: 18)
            let title = "Reporte de Productos"
            title.draw(at: CGPoint(x: 50, y: 30), withAttributes: [.font: titleFont, .foregroundColor: UIColor.black])
            
            var yPosition = 60.0
            
            // Total de productos y dinero
            let totalInfoFont = UIFont.systemFont(ofSize: 14)
            let totalText = "Total de Productos: \(cantidadTotal)\nTotal Dinero: \(totalDinero)"
            totalText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [.font: totalInfoFont, .foregroundColor: UIColor.black])
            yPosition += 50.0
            
            // Dibujar las barras de cada categoría
            for categoria in categorias {
                let productos = productosPorCategoria[categoria] ?? []
                let totalProductosCategoria = productos.reduce(0) { $0 + Int($1.cantidad) }
                let porcentajeCategoria = (Double(totalProductosCategoria) / Double(cantidadTotal)) * 100
                
                // Nombre de la categoría
                let categoriaName = categoria.nombre ?? "Desconocida"
                categoriaName.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.black])
                yPosition += 20
                
                // Dibujo de la barra de porcentaje
                let barWidth = porcentajeCategoria * 4.0  // Ajustar el tamaño de la barra
                let barRect = CGRect(x: 50, y: yPosition, width: barWidth, height: 20)
                UIColor.blue.setFill()
                context.cgContext.fill(barRect)
                yPosition += 30
            }
        }
        
        // Guardar el archivo PDF
        let filePath = getDocumentsDirectory().appendingPathComponent("Reporte_Productos.pdf")
        
        do {
            try data.write(to: filePath)
            print("PDF guardado en: \(filePath)")
            
            // Navegar al ViewController que muestra el PDF
            if let reporteVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportePDFViewController") as? ReportePDFViewController {
                reporteVC.mostrarPDF(pdfURL: filePath)
                navigationController?.pushViewController(reporteVC, animated: true)
            }
        } catch {
            print("Error al guardar el PDF: \(error)")
        }
    }
    
    // Función para obtener el directorio de documentos
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: - Métodos de TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return categorias.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoria = categorias[section]
        return productosPorCategoria[categoria]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let categoria = categorias[section]
        return categoria.nombre
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoria = categorias[indexPath.section]
        let producto = productosPorCategoria[categoria]?[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductoCell", for: indexPath)
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.textLabel?.text = producto?.nombre ?? "Sin Nombre"
        
        var detalleTexto = ""
        
        if let precio = producto?.precio, let cantidad = producto?.cantidad {
            let total = Double(precio) * Double(cantidad)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            let precioFormateado = formatter.string(from: NSNumber(value: precio)) ?? "$\(precio)"
            let totalFormateado = formatter.string(from: NSNumber(value: total)) ?? "$\(total)"
            
            detalleTexto = "Precio: \(precioFormateado)\nCantidad: \(cantidad)\nTotal: \(totalFormateado)"
        } else {
            detalleTexto = "Sin datos de precio o cantidad"
        }
        
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = detalleTexto
        
        if let imageData = producto?.imageData, let image = UIImage(data: imageData) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(named: "placeholder")
        }

        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 8
        cell.imageView?.clipsToBounds = true

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoria = categorias[indexPath.section]
        let productoSeleccionado = productosPorCategoria[categoria]?[indexPath.row]
        performSegue(withIdentifier: "SegueDetail", sender: productoSeleccionado)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueDetail" {
            if let detailVC = segue.destination as? DetailViewController {
                if let productoSeleccionado = sender as? Producto {
                    detailVC.producto = productoSeleccionado
                }
            }
        }
    }
}
