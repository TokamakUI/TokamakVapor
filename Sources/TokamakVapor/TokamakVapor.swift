//
//  Created by Max Desiatov on 02/01/2021.
//

@_exported import TokamakStaticHTML
import Vapor

extension Response {
    convenience init<V: TokamakStaticHTML.View>(view: V) {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html")
        self.init(
            status: .ok,
            headers: headers,
            body: .init(string: StaticHTMLRenderer(view).html)
        )
    }
}

extension RoutesBuilder {
    @discardableResult
    public func get<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.GET, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func get<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.GET, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func post<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.POST, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func post<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.POST, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func patch<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.PATCH, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func patch<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.PATCH, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func put<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.PUT, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func put<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.PUT, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func delete<V: TokamakStaticHTML.View>(
        _ path: PathComponent...,
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.DELETE, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func delete<V: TokamakStaticHTML.View>(
        _ path: [PathComponent],
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(.DELETE, path, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func on<V: TokamakStaticHTML.View>(
        _ method: HTTPMethod,
        _ path: PathComponent...,
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        return self.on(method, path, body: body, use: { try Response(view: closure($0)) })
    }

    @discardableResult
    public func on<V: TokamakStaticHTML.View>(
        _ method: HTTPMethod,
        _ path: [PathComponent],
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @escaping (Request) throws -> V
    ) -> Route
    {
        let responder = BasicResponder { request in
            if case .collect(let max) = body, request.body.data == nil {
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
        self.add(route)
        return route
    }
}
