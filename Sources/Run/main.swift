import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)

// startService(app: app)

defer {
    app.shutdown()
}

try configure(app)
try app.run()
