//
//  DetailViewController.swift
//  GestionAlmacenProducto
//
//  Created by Mac05 on 28/10/24.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var txtCodigo: UILabel!
    @IBOutlet weak var txtNombre: UILabel!
    @IBOutlet weak var txtCategoria: UILabel!
    @IBOutlet weak var txtCantidad: UILabel!
    @IBOutlet weak var txtPrecio: UILabel!
    @IBOutlet weak var productoImageView: UIImageView!
    
    var producto: Producto?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración minimalista para la vista
        view.backgroundColor = .systemBackground
        productoImageView.contentMode = .scaleAspectFill
        productoImageView.layer.cornerRadius = 10
        productoImageView.clipsToBounds = true

        // Mostrar detalles del producto
        if let producto = producto {
            txtCodigo.text = producto.codigo ?? "Sin Código"
            txtNombre.text = producto.nombre ?? "Sin Nombre"
            txtCategoria.text = producto.categorias?.nombre ?? "Sin Categoría"
            txtCantidad.text = "Cantidad: \(producto.cantidad)"
            txtPrecio.text = "Precio: $\(producto.precio)"
            
            // Mostrar imagen del producto
            if let imageData = producto.imageData {
                productoImageView.image = UIImage(data: imageData)
            } else {
                productoImageView.image = UIImage(named: "placeholder") // Imagen por defecto
            }
        }
    }
}
