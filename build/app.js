"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.app = void 0;
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const env_1 = require("./config/env");
const error_middleware_1 = require("./middleware/error.middleware");
const not_found_middleware_1 = require("./middleware/not-found.middleware");
const routes_1 = require("./routes");
exports.app = (0, express_1.default)();
const allowedOrigins = env_1.env.CORS_ORIGIN.split(",").map((origin) => origin.trim());
exports.app.disable("x-powered-by");
exports.app.use((0, helmet_1.default)());
exports.app.use((0, cors_1.default)({
    origin: allowedOrigins,
    credentials: true,
}));
exports.app.use(express_1.default.json({ limit: "1mb" }));
exports.app.use(express_1.default.urlencoded({ extended: true }));
if (env_1.env.NODE_ENV !== "test") {
    exports.app.use((0, morgan_1.default)(env_1.env.NODE_ENV === "production" ? "combined" : "dev"));
}
exports.app.use("/api", (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000,
    limit: 500,
    standardHeaders: "draft-8",
    legacyHeaders: false,
    message: {
        ok: false,
        message: "Demasiadas solicitudes. Intenta nuevamente más tarde.",
    },
}));
exports.app.use("/api", routes_1.router);
exports.app.use(not_found_middleware_1.notFoundMiddleware);
exports.app.use(error_middleware_1.errorMiddleware);
//# sourceMappingURL=app.js.map