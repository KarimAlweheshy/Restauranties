import * as core from "express-serve-static-core"

export interface Module {
    app: core.Express
}