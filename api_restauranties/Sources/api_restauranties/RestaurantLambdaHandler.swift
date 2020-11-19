//
//  RestaurantLambdaHandler.swift
//  
//
//  Created by Karim Alweheshy on 11/16/20.
//

import Foundation
import AWSLambdaEvents
import AWSLambdaRuntime
import AsyncHTTPClient
import NIO
import SotoDynamoDB

struct RestaurantLambdaHandler: EventLoopLambdaHandler {
   typealias In = APIGateway.Request
   typealias Out = APIGateway.Response
   let db: SotoDynamoDB.DynamoDB
   let restaurantService: RestaurantService
   let httpClient: HTTPClient

    init(context: Lambda.InitializationContext) throws {
        // HTTP Client Setup
        let timeout = HTTPClient.Configuration.Timeout(
            connect: .seconds(30),
            read: .seconds(30)
        )

        let httpClient = HTTPClient(
            eventLoopGroupProvider: .shared(context.eventLoop),
            configuration: HTTPClient.Configuration(timeout: timeout)
        )

        let awsClient = AWSClient(httpClientProvider: .shared(httpClient))

        // Retrieving Environment Variables for TableName and Region
        let tableName = Lambda.env("RESTAURANT_TABLE_NAME") ?? ""
        let region: Region
        if let envRegion = Lambda.env("AWS_REGION") {
            region = Region(rawValue: envRegion)
        } else {
            region = .uswest2
        }

        // Initializing DynamoDB and TodoService
        let db = SotoDynamoDB.DynamoDB(client: awsClient, region: region)
        let restaurantService = RestaurantService(db: db, tableName: tableName)

        // Assign to instance properties
        self.httpClient = httpClient
        self.db = db
        self.restaurantService = restaurantService
    }

    func handle(
        context: Lambda.Context,
        event: APIGateway.Request
    ) -> EventLoopFuture<APIGateway.Response> {
        guard let handler = Handler.current else {
            let response = APIGateway.Response(statusCode: .badRequest)
            return context.eventLoop.makeSucceededFuture(response)
        }

        switch handler {
        case .create:
            return handleCreate(context: context, event: event)
        case .read:
            return handleRead(context: context, event: event)
        case .update:
            return handleUpdate(context: context, event: event)
        case .delete:
            return handleDelete(context: context, event: event)
        case .list:
            return handleList(context: context, event: event)
        }
    }

    // Handling Create Todo
    func handleCreate(
        context: Lambda.Context,
        event: APIGateway.Request
    ) -> EventLoopFuture<APIGateway.Response> {
        guard let newRestaurant: Restaurant = try? event.bodyObject() else {
            let response = APIGateway.Response(statusCode: .badRequest)
            return context.eventLoop.makeSucceededFuture(response)
        }
        return restaurantService.createTodo(restaurant: newRestaurant)
            .map { todo in APIGateway.Response(with: todo, statusCode: .ok) }
            .flatMapError { self.catchError(context: context, error: $0) }
    }

    // Handling Read Todo
    func handleRead(
        context: Lambda.Context,
        event: APIGateway.Request
    ) -> EventLoopFuture<APIGateway.Response> {
        guard let id = event.pathParameters?["id"] else {
            let response = APIGateway.Response(statusCode: .notFound)
            return context.eventLoop.makeSucceededFuture(response)
        }
        return restaurantService.getRestaurant(id: id)
            .map { restaurant in APIGateway.Response(with: restaurant, statusCode: .ok) }
            .flatMapError { self.catchError(context: context, error: $0) }
    }

    // Handling Update Todo
    func handleUpdate(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        guard let updatedRestaurant: Restaurant = try? event.bodyObject() else {
            let response = APIGateway.Response(statusCode: .badRequest, body: "Missing body")
            return context.eventLoop.makeSucceededFuture(response)
        }
        return restaurantService.update(updatedRestaurant)
            .map { restaurant in APIGateway.Response(with: restaurant, statusCode: .ok) }
            .flatMapError { self.catchError(context: context, error: $0) }
    }

    // Handling Delete Todo
    func handleDelete(
        context: Lambda.Context,
        event: APIGateway.Request
    ) -> EventLoopFuture<APIGateway.Response> {
        guard let id = event.pathParameters?["id"] else {
            let response = APIGateway.Response(statusCode: .badRequest)
            return context.eventLoop.makeSucceededFuture(response)
        }
        return restaurantService.deleteRestaurant(id: id)
            .map { APIGateway.Response(statusCode: .ok) }
            .flatMapError { self.catchError(context: context, error: $0) }
    }

    // Handling Todos List
    func handleList(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        return restaurantService.getAllRestaurants()
            .map { restaurants in APIGateway.Response(statusCode: .ok) }
            .flatMapError { self.catchError(context: context, error: $0) }
    }

    // Catch Error
    func catchError(context: Lambda.Context, error: Error) -> EventLoopFuture<APIGateway.Response> {
        let response = APIGateway.Response(statusCode: .notFound, body: error.localizedDescription)
        return context.eventLoop.makeSucceededFuture(response)
    }
}

