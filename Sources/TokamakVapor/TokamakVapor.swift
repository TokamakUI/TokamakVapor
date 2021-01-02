//
//  Created by Max Desiatov on 02/01/2021.
//

import TokamakStaticHTML
import Vapor

extension HTML: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html")
        return request.eventLoop.makeSucceededFuture(.init(
            status: .ok, headers: headers, body: .init(string: StaticHTMLRenderer(self).html)
        ))
    }
}
