import UIKit
import CoreData

class ProductosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var productoTableView: UITableView!
    @IBOutlet weak var txtCantidadTotalProductos: UITextField!
    @IBOutlet weak var txtTotalDineroProductos: UITextField!
    
    var categorias: [Categoria] = []
    var productosPorCategoria: [Categoria: [Producto]] = [:]
    
    var cantidadTotal: Int = 0
    var totalDinero: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        productoTableView.delegate = self
        productoTableView.dataSource = self

        obtenerCategoriasYProductos()

        txtCantidadTotalProductos.isUserInteractionEnabled = false
        txtTotalDineroProductos.isUserInteractionEnabled = false

        // Configuración del botón de exportación en PDF
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Exportar PDF", style: .plain, target: self, action: #selector(exportarPDF))
    }

    func obtenerCategoriasYProductos() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Categoria> = Categoria.fetchRequest()

        do {
            categorias = try contexto.fetch(fetchRequest)
            for categoria in categorias {
                let productos = categoria.productos?.allObjects as! [Producto]
                productosPorCategoria[categoria] = productos
            }
            calcularTotales()
            productoTableView.reloadData()
        } catch {
            print("Error al obtener categorías y productos: \(error)")
        }
    }

    func calcularTotales() {
        cantidadTotal = 0
        totalDinero = 0.0
        for categoria in categorias {
            if let productos = productosPorCategoria[categoria] {
                for producto in productos {
                    if producto.precio > 0, producto.cantidad > 0 {
                        cantidadTotal += Int(producto.cantidad)
                        totalDinero += Double(producto.cantidad) * producto.precio
                    }
                }
            }
        }
        txtCantidadTotalProductos.text = "\(cantidadTotal)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let totalFormateado = formatter.string(from: NSNumber(value: totalDinero)) {
            txtTotalDineroProductos.text = totalFormateado
        }
    }

    @objc func exportarPDF() {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: 595, height: 842), nil)
        
        let context = UIGraphicsGetCurrentContext()
        
        UIGraphicsBeginPDFPage()
        
        var yOffset: CGFloat = 20
        let leftMargin: CGFloat = 20
        let lineSpacing: CGFloat = 30

        // Título del reporte
        let title = "Reporte de Kardex de Productos"
        title.draw(at: CGPoint(x: leftMargin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
        yOffset += lineSpacing + 10

        // Dibuja el gráfico de torta
        yOffset = drawPieChart(context: context, x: leftMargin + 150, y: yOffset + 100, radius: 100)

        yOffset += 60 // Espacio después del gráfico de torta

        // Iteramos por cada categoría y sus productos
        for categoria in categorias {
            let categoriaName = "Categoría: \(categoria.nombre ?? "Sin nombre")"
            categoriaName.draw(at: CGPoint(x: leftMargin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            yOffset += lineSpacing

            if let productos = productosPorCategoria[categoria] {
                for producto in productos {
                    let nombre = producto.nombre ?? "Sin nombre"
                    let precio = producto.precio
                    let cantidad = producto.cantidad
                    let total = Double(cantidad) * precio
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    let precioFormateado = formatter.string(from: NSNumber(value: precio)) ?? "$\(precio)"
                    let totalFormateado = formatter.string(from: NSNumber(value: total)) ?? "$\(total)"
                    
                    let productoInfo = "Producto: \(nombre) | Precio: \(precioFormateado) | Cantidad: \(cantidad) | Total: \(totalFormateado)"
                    productoInfo.draw(at: CGPoint(x: leftMargin, y: yOffset), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                    yOffset += lineSpacing

                    // Verificar si queda espacio en la página
                    if yOffset > 780 {
                        UIGraphicsBeginPDFPage()
                        yOffset = 20
                    }
                }
            }
            yOffset += lineSpacing
        }

        // Totales generales
        yOffset += 20
        let cantidadTotalText = "Cantidad total de productos: \(cantidadTotal)"
        cantidadTotalText.draw(at: CGPoint(x: leftMargin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        yOffset += lineSpacing
        let totalDineroText = "Dinero total de productos: \(txtTotalDineroProductos.text ?? "$0.00")"
        totalDineroText.draw(at: CGPoint(x: leftMargin, y: yOffset), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 14)])

        UIGraphicsEndPDFContext()
        
        // Guardar el PDF en los documentos
        let pdfURL = getDocumentsDirectory().appendingPathComponent("ReporteKardexProductos.pdf")
        pdfData.write(to: pdfURL, atomically: true)
        
        // Compartir el PDF
        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    func drawPieChart(context: CGContext?, x: CGFloat, y: CGFloat, radius: CGFloat) -> CGFloat {
        var startAngle: CGFloat = 0
        var yOffset = y

        let categoryTotals = categorias.map { categoria in
            productosPorCategoria[categoria]?.reduce(0) { $0 + Int($1.cantidad) } ?? 0
        }

        let totalProductos = categoryTotals.reduce(0, +)

        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple]

        for (index, categoria) in categorias.enumerated() {
            let categoryTotal = categoryTotals[index]
            let percentage = CGFloat(categoryTotal) / CGFloat(totalProductos)
            let endAngle = startAngle + (2 * .pi * percentage)

            context?.setFillColor(colors[index % colors.count].cgColor)
            context?.move(to: CGPoint(x: x, y: y))
            context?.addArc(center: CGPoint(x: x, y: y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context?.fillPath()

            // Dibujar etiqueta de porcentaje
            let midAngle = (startAngle + endAngle) / 2
            let labelX = x + radius * 0.7 * cos(midAngle)
            let labelY = y + radius * 0.7 * sin(midAngle)
            let labelText = String(format: "%.1f%%", percentage * 100)
            labelText.draw(at: CGPoint(x: labelX, y: labelY), withAttributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black])

            startAngle = endAngle
            yOffset += 20
        }

        return yOffset + radius * 2
    }

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
}
