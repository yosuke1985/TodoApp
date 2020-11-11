# iOS Sample Todo Application build with Clean Architecture + Router a.k.a Viper

## UI

## Requirements

- Clean Architecture + Router a.k.a Viper
- Swift 5
- iOS14
- RxSwift
- Firebase
- Firestore

## Class Chart

<img src="https://docs.google.com/drawings/d/e/2PACX-1vSgHoUQDGKzsEiM8oaBD5dv5hGxEjHILlpnIOmOni308qQD79W35BrA6kxwEhBwugF1GkaJ81hF8meF/pub?w=960&amp;h=720">

## Naming conventions

|  役割 | 抽象型 | 具象型 |
| --- | --- | --- |
|  View | | (ModuleName)View, (ModuleName)ViewController |
|  Presenter | (ModuleName)Presenter | (ModuleName)PresenterImpl |
|  UseCase | (ModuleName)UseCase | (ModuleName)UseCaseImpl |
|  Entity |  | Entity |
|  Router | (ModuleName)Router | (ModuleName)RouterImpl |
|  Repository | (ModuleName)Repository | (ModuleName)RepositoryImpl |

## File Structure of the Program

\<P> = Protocol

- Entity
  - Todo.swift

- Usecase
  - LoginUsecase.swift
    - \<P>LoginUsecaseInjectable
    - \<P>LoginUsecase
    - LoginUsecaseImpl
  - TodoUsecase.swift
    - \<P>TodoUsecaseInjectable
    - \<P>TodoUseCase
    - TodoUseCaseImpl

- Data
  - Repository
    - LoginRepository.swift
      - \<P>LoginRepositoryInjectable
      - \<P>LoginRepository
      - LoginRepositoryImpl
    - TodoRepository.swift
      - \<P>TodoRepositoryInjectable
      - \<P>TodoRepository
      - TodoRepositoryImpl
  - RequestResponse
    - Login
      - LoginRequest.swift
      - LoginResponse.swift
    - Todo
      - TodoRequest.swift
      - TodoResponse.swift

- Presentation
  - LoginView
    - View
      - LoginViewController.swift
    - Presenter
      - LoginPresenter.swift
        - \<P>LoginPresenterInjectable
        - \<P>LoginPresenter
        - LoginPresenterImpl
    - Router
      - LoginRouter.swift
        - \<P>LoginTransitionble
        - \<P>LoginRouterInjectable
        - \<P>LoginRouter
        - LoginRouterImpl
      - Builder
        - LoginBuilder.swift

  - TodoListView
    - View
      - TodoListViewController.swift
    - Presenter
      - TodoListPresenter.swift
        - \<P>TodoListPresenterInjectable
        - \<P>TodoListPresenter
        - TodoListPresenterImpl
    - Router
      - TodoListRouter.swift
      - \<P>TodoListTransitionable
      - \<P>TodoListRouterInjectable
      - \<P>TodoListRouter
      - TodoListRouterImpl
    - Builder
      - TodoListBuilder.swift

  - TodoDetail
    - View
      - TodoDetailViewController.swift
    - Presenter
      - TodoDetailPresenter.swift
        - \<P>TodoDetailInjectable
        - \<P>TodoDetailPresenter
        - TodoDetailPresenterImpl
    - Router
      - TodoDetailRouter.swift
        - \<P>TodoDetailTransitionable
        - \<P>TodoDetailRouterInjectable
        - \<P>TodoDetailRouter
        - TodoDetailRouterImpl
    - Builder
      - TodoDetailBuilder.swift

## 注釈

1. Clean Architecture + Routerのアーキテクチャ　＝　VIPERであり、VIPERはView Interactor Presenter Entity Routerの頭文字を取ったもの。
2. VIPERでは UseCaseのことをInteractorと名付けている。
3. protocolとそれを準拠したクラスないしは構造体は、protocolの名称 + Implと命名する。
4. DIの部分は、protocolの**Injectable.protocolを作成し、protocol extensionに実体を配置する
5. 画面遷移にはRouterパターンを採用。画面遷移部分を切り離す。各Routerに対応したUIViewControllerの参照を持ち、Presenterから受けた入力によって画面遷移させる。
6. BuilderはPresenter, UseCase, RouterをDIさせる。
7. 各Transitionableは、buildして画面遷移する責務を持つ。各Transitionableに準拠したRouter(UIViewControllerの実体を持つ)は、その準拠した画面へ遷移することができるようになる。（遷移するための実装がそのTransitionableにあるので）

## Reference

- 実装クリーンアーキテクチャ
<https://qiita.com/nrslib/items/a5f902c4defc83bd46b8>

- Viper研究読本 VIPER研究読本1 クリーンアーキテクチャ解説編
  <https://swift.booth.pm/items/1758609>

- iOSアプリ設計入門　<https://peaks.cc/books/iOS_architecture>
