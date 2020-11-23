import * as core from "express-serve-static-core"
import { AuthenticationMiddleware } from '../middleware/authentication_middleware'

export interface Module {
    appForModule(authenticationMiddleware: AuthenticationMiddleware): core.Express
}