import * as core from "express-serve-static-core"
import { ServiceFactory } from '../factories/service_factory'
import { AuthenticationMiddleware } from '../middleware/authentication_middleware'

export interface Module {
    pathPrefix: string
    
    appForModule(authenticationMiddleware: AuthenticationMiddleware): core.Express
}

export interface ModuleConstructor {
    new(factory: ServiceFactory): Module
}