"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.env = void 0;
require("dotenv/config");
const zod_1 = require("zod");
const envSchema = zod_1.z.object({
    NODE_ENV: zod_1.z
        .enum(["development", "test", "production"])
        .default("development"),
    PORT: zod_1.z.coerce.number().int().positive().default(3000),
    CORS_ORIGIN: zod_1.z.string().min(1).default("http://localhost:5173"),
    DB_HOST: zod_1.z.string().min(1),
    DB_PORT: zod_1.z.coerce.number().int().positive().default(3306),
    DB_USER: zod_1.z.string().min(1),
    DB_PASSWORD: zod_1.z.string(),
    DB_NAME: zod_1.z.string().min(1),
    DB_CONNECTION_LIMIT: zod_1.z.coerce.number().int().positive().default(10),
    JWT_SECRET: zod_1.z.string().min(32),
    JWT_EXPIRES_IN: zod_1.z.string().default("8h"),
});
const result = envSchema.safeParse(process.env);
if (!result.success) {
    console.error("Variables de entorno inválidas:");
    for (const issue of result.error.issues) {
        console.error(`- ${issue.path.join(".")}: ${issue.message}`);
    }
    process.exit(1);
}
exports.env = result.data;
//# sourceMappingURL=env.js.map