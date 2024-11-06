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
    
    var producto: Producto?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let producto = producto {
            txtCodigo.text = producto.codigo ?? "Sin Código"
            txtNombre.text = producto.nombre ?? "Sin Nombre"
            txtCategoria.text = producto.categorias?.nombre
            
            ?? "Sin Categoria"
            txtCantidad.text = String(producto.cantidad)
            txtPrecio.text = String(producto.precio)
        }
    }
}
