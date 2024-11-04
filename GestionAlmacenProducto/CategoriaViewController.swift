import UIKit
import CoreData

class CategoriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categoriaTableView: UITableView!
    
    var categorias: [Categoria] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        categoriaTableView.delegate = self
        categoriaTableView.dataSource = self
        loadCategorias()  // Cargar las categorías iniciales
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCategorias()  // Cargar las categorías cada vez que la vista aparece
    }
    
    func loadCategorias() {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Categoria> = Categoria.fetchRequest()
        
        do {
            categorias = try contexto.fetch(fetchRequest)
            categoriaTableView.reloadData()
        } catch {
            print("Error al cargar las categorías: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CategoriaCell")
        let categoria = categorias[indexPath.row]
        cell.textLabel?.text = categoria.nombre
        cell.detailTextLabel?.text = categoria.descripcion
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let categoria = categorias[indexPath.row]

        // Acción de editar
        let editAction = UIContextualAction(style: .normal, title: "Editar") { (action, view, completionHandler) in
            self.performSegue(withIdentifier: "segueAgregarEditar", sender: categoria)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue

        // Acción de eliminar
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { (action, view, completionHandler) in
            self.deleteCategoria(at: indexPath)
            completionHandler(true)
        }

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }

    func deleteCategoria(at indexPath: IndexPath) {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        contexto.delete(categorias[indexPath.row])
        
        do {
            try contexto.save()
            categorias.remove(at: indexPath.row)
            categoriaTableView.deleteRows(at: [indexPath], with: .fade)
        } catch {
            print("Error al eliminar la categoría: \(error)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAgregarEditar" {
            let agregarVC = segue.destination as! AgregarCategoriaViewController
            agregarVC.categoria = sender as? Categoria // Pasa la categoría seleccionada
        }
    }
}
