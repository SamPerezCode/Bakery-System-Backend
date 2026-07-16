"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorMiddleware = void 0;
const zod_1 = require("zod");
const env_1 = require("../config/env");
const app_error_1 = require("../utils/app-error");
const errorMiddleware = (error, _req, res, _next) => {
    if (error instanceof zod_1.ZodError) {
        res.status(400).json({
            ok: false,
            message: "Datos de entrada inválidos",
            errors: error.issues,
        });
        return;
    }
    if (error instanceof app_error_1.AppError) {
        res.status(error.statusCode).json({
            ok: false,
            message: error.message,
            details: error.details,
        });
        return;
    }
    console.error(error);
    res.status(500).json({
        ok: false,
        message: "Error interno del servidor",
        ...(env_1.env.NODE_ENV === "development" && error instanceof Error
            ? { error: error.message, stack: error.stack }
            : {}),
    });
};
exports.errorMiddleware = errorMiddleware;
//# sourceMappingURL=error.middleware.js.map