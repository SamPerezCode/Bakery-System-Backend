"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.router = void 0;
const express_1 = require("express");
const database_1 = require("../config/database");
exports.router = (0, express_1.Router)();
exports.router.get("/health", async (_req, res) => {
    await database_1.pool.query("SELECT 1");
    res.status(200).json({
        ok: true,
        message: "Bakery System API funcionando",
        database: "connected",
        timestamp: new Date().toISOString(),
    });
});
//# sourceMappingURL=index.js.map