"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notFoundMiddleware = notFoundMiddleware;
function notFoundMiddleware(req, res) {
    res.status(404).json({
        ok: false,
        message: `Ruta no encontrada: ${req.method} ${req.originalUrl}`,
    });
}
//# sourceMappingURL=not-found.middleware.js.map