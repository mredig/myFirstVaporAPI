import Vapor
import FluentSQLite

/// Controls basic CRUD operations on `Todo`s.
final class TodoController: RouteCollection {

	func boot(router: Router) throws {
		// POST a user in the `httpBody`, we want to save it to the database
		router.post("todos", "create", use: createTodoHandler)
		router.get("todos", "all", use: getAllTodosHandler)
		router.get("todos", Int.parameter, use: getTodoWithIDHandler)
		router.delete("todos", Int.parameter, use: deleteTodoWithIDHandler)
	}

	func getTodoWithIDHandler(_ request: Request) throws -> Future<Todo> {
		let idParameter = try request.parameters.next(Int.self)

		let todo = Todo
			.query(on: request)
//			.filter(\.id, .equal, idParameter)
			.filter(\.id == idParameter)
			.first()
			.unwrap(or: HTTPError(identifier: "com.myFirstAPI", reason: "No todo with that ID: \(idParameter)"))

		return todo
	}

	func deleteTodoWithIDHandler(_ request: Request) throws -> Future<HTTPResponseStatus> {
		let idParameter = try request.parameters.next(Int.self)
		return Todo.query(on: request)
			.filter(\.id == idParameter)
			.first()
			.unwrap(or: HTTPError(identifier: "com.myFirstAPI", reason: "No todo with that ID: \(idParameter)"))
			.delete(on: request)
			.transform(to: HTTPResponseStatus.ok)
	}

	func getAllTodosHandler(_ request: Request) throws -> Future<[Todo]> {
		return Todo.query(on: request).all()
	}

	func createTodoHandler(_ request: Request) throws -> Future<HTTPResponseStatus> {
		let todo = try request.content
			.decode(Todo.self)

		let result = todo.flatMap({ (todo) -> EventLoopFuture<HTTPResponseStatus> in
				_ = todo.save(on: request)
				let promise = request.eventLoop.newPromise(HTTPResponseStatus.self)
				promise.succeed(result: .created)
				return promise.futureResult
			})

		return result
	}
}
