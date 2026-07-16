"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = require("./app");
const database_1 = require("./config/database");
const env_1 = require("./config/env");
async function closeServer(server, signal) {
    console.log(`\nSeñal ${signal} recibida. Cerrando servidor...`);
    server.close(async () => {
        await database_1.pool.end();
        console.log("Servidor y conexiones cerrados");
        process.exit(0);
    });
    setTimeout(() => {
        console.error("Cierre forzado por tiempo de espera");
        process.exit(1);
    }, 10_000).unref();
}
async function bootstrap() {
    await (0, database_1.checkDatabaseConnection)();
    console.log("Conexión con MySQL establecida");
    const server = app_1.app.listen(env_1.env.PORT, () => {
        console.log(`Bakery System API ejecutándose en http://localhost:${env_1.env.PORT}`);
    });
    process.once("SIGINT", () => {
        void closeServer(server, "SIGINT");
    });
    process.once("SIGTERM", () => {
        void closeServer(server, "SIGTERM");
    });
}
bootstrap().catch((error) => {
    console.error("No fue posible iniciar el servidor:", error);
    process.exit(1);
});
//# sourceMappingURL=index.js.map