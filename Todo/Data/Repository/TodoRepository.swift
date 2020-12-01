//
//  TodoRepository.swift
//  Todo
//
//  Created by yosuke.nakayama on 2020/11/06.
//

import Firebase
import FirebaseFirestoreSwift
import RxCocoa
import RxSwift

protocol TodoRepositoryInjectable {
    var todoRepository: TodoRepository { get }
}

extension TodoRepositoryInjectable {
    var todoRepository: TodoRepository {
        return TodoRepositoryImpl.shared
    }
}

protocol TodoRepository {
    func startListenTodos() -> Completable
    func removeTodosListener()
    func todosRelay() -> Driver<[SectionTodo]>
    func add(title: String, description: String) -> Completable
    func isChecked(todoId: String, isChecked: Bool) -> Completable
    func updateTitle(todoId: String, title: String) -> Completable
    func updateDescription(todoId: String, description: String) -> Completable
    func delete(todoId: String) -> Completable
}

class TodoRepositoryImpl: TodoRepository {
    static var shared = TodoRepositoryImpl()
    var _todosTableViewRelay = BehaviorRelay<[SectionTodo]>(value: [])
    var todosTableViewRelay: Driver<[SectionTodo]> {
        return _todosTableViewRelay.asDriver()
    }

    var snapshotListener: ListenerRegistration!

    private init() {}

    func startListenTodos() -> Completable {
        guard let userId = Auth.auth().currentUser?.uid else { return Completable.empty() }
        return Completable.create { [weak self] (observer) -> Disposable in
            guard let weakSelf = self else { return Disposables.create() }
            if weakSelf.snapshotListener == nil {
                weakSelf.snapshotListener = Firestore.firestore().collection("users/\(userId)/todos").order(by: "updatedAt").addSnapshotListener
                    { snapshot, error in
                        if let error = error {
                            weakSelf._todosTableViewRelay.accept([])
                            observer(.error(error))
                        } else if let snapshot = snapshot?.documents.first {
                            var todos: [Todo] = []
                            do {
                                todos = try snapshot.data(as: [Todo].self)!
                                let sectionTodo = [SectionTodo(header: "", items: todos)]
                                weakSelf._todosTableViewRelay.accept(sectionTodo)
                                observer(.completed)
                            } catch {
                                print(error)
                                observer(.error(error))
                            }
                        }
                    }
            } else {
                if weakSelf.snapshotListener != nil {
                    weakSelf.snapshotListener.remove()
                    weakSelf.snapshotListener = nil
                    weakSelf._todosTableViewRelay.accept([])
                }
            }
            
            return Disposables.create()
        }
    }
    
    func todosRelay() -> Driver<[SectionTodo]> {
        return todosTableViewRelay
    }

    func removeTodosListener() {
        snapshotListener.remove()
    }

    func add(title: String, description: String = "") -> Completable {
        guard let userId = Auth.auth().currentUser?.uid else { return Completable.empty() }
        // TODO: need no user login Error

        return Completable.create { (observer) -> Disposable in
            Firestore.firestore().collection("users/\(userId)/todos").document().setData([
                "title": title,
                "description": description,
                "createdAt": Date()
            ], completion: { error in
                if let error = error {
                    observer(.error(error))
                } else {
                    observer(.completed)
                }
            })

            return Disposables.create()
        }
    }

    func isChecked(todoId: String, isChecked: Bool) -> Completable {
        guard let userId = Auth.auth().currentUser?.uid else { return Completable.empty() }

        return Completable.create { (observer) -> Disposable in
            Firestore.firestore().collection("users/\(userId)/todos").document(todoId).updateData(
                [
                    "isChecked": isChecked,
                    "updatedAt": Date()
                ],
                completion: { error in
                    if let error = error {
                        observer(.error(error))

                    } else {
                        observer(.completed)
                    }
                }
            )
            
            return Disposables.create()
        }
    }

    func updateTitle(todoId: String, title: String) -> Completable {
        guard let userId = Auth.auth().currentUser?.uid else { return Completable.empty() }
        return Completable.create { (observer) -> Disposable in

            Firestore.firestore().collection("users/\(userId)/todos").document(todoId).updateData(
                ["title": title,
                 "updatedAt": Date()],
                completion: { error in
                    if let error = error {
                        observer(.error(error))
                    } else {
                        observer(.completed)
                    }
                }
            )
            return Disposables.create()
        }
    }

    func updateDescription(todoId: String, description: String) -> Completable {
        guard let userId = Auth.auth().currentUser?.uid else { return Completable.empty() }
        return Completable.create { (observer) -> Disposable in
            Firestore.firestore().collection("users/\(userId)/todos").document(todoId).updateData(
                ["description": description,
                 "updatedAt": Date()],
                completion: { error in
                    if let error = error {
                        observer(.error(error))
                    } else {
                        observer(.completed)
                    }
                }
            )
            return Disposables.create()
        }
    }

    func delete(todoId: String) -> Completable {
        Completable.create { (observer) -> Disposable in
            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users/\(userId)/todos").document(todoId).delete { error in
                    if let error = error {
                        observer(.error(error))

                    } else {
                        observer(.completed)
                    }
                }
            }
            return Disposables.create()
        }
    }
}
