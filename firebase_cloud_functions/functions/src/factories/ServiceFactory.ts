import * as Core from 'express-serve-static-core'
import * as Express from 'express'
import * as bodyParser from 'body-parser'

export interface ServiceFactory {
    makeNewService(): Core.Express
}

export class DefaultServiceFactory implements ServiceFactory {
    makeNewService(): Core.Express {
        const service = Express()
        service.use(bodyParser.json())
        return service
    }
}