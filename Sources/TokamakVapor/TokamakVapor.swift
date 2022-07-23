//
//  Created by Max Desiatov on 02/01/2021.
//

@_exported
import TokamakStaticHTML

import Vapor

extension Response {
    convenience init<V: TokamakStaticHTML.View>(view: V) {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html")
        self.init(
            status: .ok,
            headers: headers,
            body: .init(string: StaticHTMLRenderer(view).render(shouldSortAttributes: true))
        )
    }
}

public extension RoutesBuilder {
    @discardableResult
    func get<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.GET, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func get<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.GET, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func post<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.POST, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func post<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.POST, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func patch<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.PATCH, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func patch<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.PATCH, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func put<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.PUT, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func put<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.PUT, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func delete<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.DELETE, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func delete<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(.DELETE, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func on<V: TokamakStaticHTML.View>(
        _ method: HTTPMethod,
        _ path: PathComponent...,
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        return on(method, path, body: body, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    func on<V: TokamakStaticHTML.View>(
        _ method: HTTPMethod,
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @escaping (Request) throws -> V
    ) -> Route {
        let responder = BasicResponder { request in
            if case let .collect(max) = body, request.body.data == nil {
                return request.body.collect(
                    max: max?.value ?? request.application.routes.defaultMaxBodySize.value
                ).flatMapThrowing { _ in
                    try Response(view: closure(request))
                }.encodeResponse(for: request)
            } else {
                return try Response(view: closure(request))
                    .encodeResponse(for: request)
            }
        }
        let route = Route(
            method: method,
            path: path,
            responder: responder,
            requestType: Request.self,
            responseType: Response.self
        )
        add(route)
        return route
    }
}
