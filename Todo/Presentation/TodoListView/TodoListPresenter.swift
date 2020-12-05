//
//  TodoListPresenter.swift
//  Todo
//
//  Created by Yosuke Nakayama on 2020/11/13.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct SectionTodo {
    var header: String
    var items: [Item]
}

// AnimatableSectionModelType
extension SectionTodo: AnimatableSectionModelType {
    typealias Item = Todo
    typealias Identity = String

    var identity: String {
        return header
    }
    
    init(original: SectionTodo, items: [Item]) {
        self = original
        self.items = items
    }
}

// MARK: - <P>TodoListPresenter

protocol TodoListPresenter {
    var router: TodoListRouter! { get set }
    var todoUseCase: TodoUseCase! { get set }
    
    var todoTableViewRelay: BehaviorRelay<[SectionTodo]> { get }
    var willDeleteTodoRelay: PublishRelay<Todo> { get }
    
    func setup()
    func tearDown()
    
    var updateIsCheckedRelay: PublishRelay<Todo> { get }
    
    func logout()
    func toLoginView()
    func toTodoDetailView(todo: Todo)
    func toCreateTodoView()
    
    var showAPIErrorPopupRelay: Signal<Error> { get }
}

// MARK: - TodoListPresenterImpl

final class TodoListPresenterImpl: TodoListPresenter {
    let bag = DisposeBag()
    var router: TodoListRouter!
    var todoUseCase: TodoUseCase!
    var authUseCase: AuthUseCase!
    
    var todoTableViewRelay = BehaviorRelay<[SectionTodo]>(value: [])
    private let _showAPIErrorPopupRelay = PublishRelay<Error>()
    var showAPIErrorPopupRelay: Signal<Error> {
        return _showAPIErrorPopupRelay.asSignal()
    }

    var willDeleteTodoRelay = PublishRelay<Todo>()
    var updateIsCheckedRelay = PublishRelay<Todo>()

    func setup() {
        setBind()
    }
    
    func setBind() {
        todoUseCase.startListenTodos()
            .subscribe(onError: { [weak self] error in
                self?._showAPIErrorPopupRelay.accept(error)
            })
            .disposed(by: bag)
                
        todoUseCase.todosRelay()
            .drive(todoTableViewRelay)
            .disposed(by: bag)
        
        willDeleteTodoRelay
            .flatMap { [weak self] todo -> Single<Void> in
                guard let weakSelf = self else { return Single<Void>.error(CustomError.selfIsNil) }
                return weakSelf.todoUseCase.delete(todo: todo)
                    .andThen(Single<Void>.just(()))
            }
            .subscribe(onError: { [weak self] error in
                self?._showAPIErrorPopupRelay.accept(error)
            })
            .disposed(by: bag)
        
        updateIsCheckedRelay
            .flatMap { [weak self] (todo) -> Single<Void> in
                guard let weakSelf = self else { return Single<Void>.error(CustomError.selfIsNil) }
                return weakSelf.todoUseCase.update(todo: todo)
                    .andThen(Single<Void>.just(()))
            }
            .subscribe(onError: { [weak self] error in
                self?._showAPIErrorPopupRelay.accept(error)
            })
            .disposed(by: bag)
    }
    
    func tearDown() {
        todoUseCase.tearDown()
    }
    
    func isChecked(todoId: String, isChecked: Bool) {}

    func logout() {
        authUseCase.logout()
            .subscribe { [weak self] result in
                guard let weakSelf = self else { return }
                switch result {
                case .success:
                    weakSelf.toLoginView()
                case let .error(error):
                    weakSelf._showAPIErrorPopupRelay.accept(error)
                }
            }
            .disposed(by: bag)
    }

    func toLoginView() {
        router.toLoginView()
    }
    
    func toTodoDetailView(todo: Todo) {
        router.toTodoDetailView(todo: todo)
    }
    
    func toCreateTodoView() {
        router.toCreateTodoView()
    }
}
