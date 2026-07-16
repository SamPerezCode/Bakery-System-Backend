import type { Server } from "node:http";
import { app } from "./app";
import { checkDatabaseConnection, pool } from "./config/database";
import { env } from "./config/env";

async function closeServer(
  server: Server,
  signal: NodeJS.Signals
): Promise<void> {
  console.log(`\nSeñal ${signal} recibida. Cerrando servidor...`);

  server.close(async () => {
    await pool.end();
    console.log("Servidor y conexiones cerrados");
    process.exit(0);
  });

  setTimeout(() => {
    console.error("Cierre forzado por tiempo de espera");
    process.exit(1);
  }, 10_000).unref();
}

async function bootstrap(): Promise<void> {
  await checkDatabaseConnection();
  console.log("Conexión con MySQL establecida");

  const server = app.listen(env.PORT, () => {
    console.log(
      `Bakery System API ejecutándose en http://localhost:${env.PORT}`
    );
  });

  process.once("SIGINT", () => {
    void closeServer(server, "SIGINT");
  });

  process.once("SIGTERM", () => {
    void closeServer(server, "SIGTERM");
  });
}

bootstrap().catch((error: unknown) => {
  console.error("No fue posible iniciar el servidor:", error);
  process.exit(1);
});
