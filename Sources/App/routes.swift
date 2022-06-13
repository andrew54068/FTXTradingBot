import Fluent
import Vapor
// import RxSwift

func routes(_ app: Application) throws {
    app.get { req in
        req.view.render("index.leaf", ["title": "Hello Vapor!"])
    }

    app.get { req -> EventLoopFuture<OrderResponseModel> in
        req.application.threadPool.runIfActive(eventLoop: req.eventLoop) {
            do {
                return try await startService(app: app).get()
            } catch {
                let promise = req.eventLoop.makePromise(of: OrderResponseModel.self)
                promise.fail(<#T##Error#>)
                return promise.futureResult
            }
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
