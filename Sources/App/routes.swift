import Fluent
import Foundation
import Vapor

func routes(_ app: Application) throws {
//    app.get { req in
//        req.view.render("index.leaf", ["title": "Hello Vapor!"])
//    }

    app.get { _ -> EventLoopFuture<String> in
        startService(app: app).flatMapThrowing { orderResponseModel in
            let encoder = JSONEncoder()
            let data = try encoder.encode(orderResponseModel)
            let result = String(data: data, encoding: .utf8) ?? ""
            app.logger.log(level: .info, .init(stringLiteral: result))
            return result
        }
    }

    app.post("orders") { req -> String in
        req.logger.info("\(req.body)")
        req.logger.info("\(req.headers)")
        req.logger.info("\(req.method)")
        req.logger.info("\(req.parameters)")
        return "\(req.body)\(req.headers)\(req.method)"
    }
}
