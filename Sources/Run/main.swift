import App
import Vapor
import Jobs

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)

Jobs.add(interval: .seconds(5)) {
    startService(app: app)
}

defer {
    app.shutdown()
}
try configure(app)
try app.run()
