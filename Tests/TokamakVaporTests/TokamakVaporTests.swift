//
//  Created by Max Desiatov on 02/01/2021.
//

@testable
import TokamakVapor

import class Vapor.Response
import XCTest

struct Hello: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
            Text("Some red text below")
                .foregroundColor(.red)
        }
    }
}

final class TokamakVaporTests: XCTestCase {
    func testHello() {
        let view = Hello()

        XCTAssertEqual(
            Response(view: view).description.count,
            """
            HTTP/1.1 200 OK
            content-type: text/html
            content-length: 3151
            \(StaticHTMLRenderer(view).render(shouldSortAttributes: true).description)
            """.count
        )
    }
}
