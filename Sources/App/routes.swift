import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let todoController = TodoController()
	try router.register(collection: todoController)
}
