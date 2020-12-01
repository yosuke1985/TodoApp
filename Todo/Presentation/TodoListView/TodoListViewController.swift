//
//  TodoListViewController.swift
//  Todo
//
//  Created by Yosuke Nakayama on 2020/11/13.
//

import Firebase
import RxCocoa
import RxDataSources
import RxSwift
import UIKit
    
class TodoListViewController: UIViewController {
    var presenter: TodoListPresenter!
    var bag = DisposeBag()
    
    @IBOutlet weak var toCreateTodoButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(TodoCell.nib, forCellReuseIdentifier: TodoCell.identifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userSession = AuthRepositoryImpl.shared.userRelay.value
        print("userSession", userSession)
        
        setUI()
        setTableViewBind()
        presenter.setup()
        setBind()
    }
    
    deinit {
        presenter.tearDown()
    }
    
    @objc private func logout() {
        presenter.logout()
    }
}

extension TodoListViewController {
    private func setUI() {
        let leftButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logout))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    private func setBind() {
        toCreateTodoButton.rx.tap
            .subscribe { [weak self] _ in
                self?.presenter.toCreateTodoView()
            }
            .disposed(by: bag)
        
        presenter.showAPIErrorPopupRelay
            .emit(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: bag)
    }
}

extension TodoListViewController: UITableViewDelegate {
    func setTableViewBind() {
        let dataSource = returnDataSource()
//
//        let sections = [
//            SectionTodo(header: "Genre1", items: [
//                Todo(id: "id1", title: "todo1", description: "description1", isChecked: true, createdAt: Date(), updatedAt: Date()),
//                Todo(id: "id1", title: "todo2", description: "description1", isChecked: true, createdAt: Date(), updatedAt: Date()),
//                Todo(id: "id1", title: "todo3", description: "description1", isChecked: true, createdAt: Date(), updatedAt: Date()),
//                Todo(id: "id1", title: "todo4", description: "description1", isChecked: true, createdAt: Date(), updatedAt: Date()),
//                Todo(id: "id1", title: "todo5", description: "description1", isChecked: true, createdAt: Date(), updatedAt: Date())
//            ])
//        ]
//
//        presenter.todoTableViewRelay.accept(sections)
                                
        presenter.todoTableViewRelay
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.setDelegate(self).disposed(by: bag)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.toTodoDetailView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func returnDataSource() -> RxTableViewSectionedAnimatedDataSource<SectionTodo> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.identifier, for: indexPath) as! TodoCell
                cell.todoName?.text = "\(item.title)"
                return cell
            },
            canEditRowAtIndexPath: { _, _ in
                true
            },
            canMoveRowAtIndexPath: { _, _ in
                true
            }
        )
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, handler in
            
            self?.presenter.deletedTodoRelay.accept(indexPath)
            handler(true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])

        return swipeActions
    }
}
