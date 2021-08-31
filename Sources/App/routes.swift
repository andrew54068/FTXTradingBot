import Fluent
import Vapor

func routes(_ app: Application) throws {
//    app.get { req in
//        return req.view.render("index.leaf", ["title": "Hello Vapor!"])
//    }
    
    app.get { req in
        return "It works!"
    }

    app.post("orders") { req -> String in
        req.logger.info("\(req.body)")
        req.logger.info("\(req.headers)")
        req.logger.info("\(req.method)")
        req.logger.info("\(req.parameters)")
        return "\(req.body)\(req.headers)\(req.method)"
    }

}
