import cors from "cors";
import express from "express";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import morgan from "morgan";
import { env } from "./config/env";
import { errorMiddleware } from "./middleware/error.middleware";
import { notFoundMiddleware } from "./middleware/not-found.middleware";
import { router } from "./routes";

export const app = express();

const allowedOrigins = env.CORS_ORIGIN.split(",").map((origin) =>
  origin.trim()
);

app.disable("x-powered-by");

app.use(helmet());

app.use(
  cors({
    origin: allowedOrigins,
    credentials: true,
  })
);

app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true }));

if (env.NODE_ENV !== "test") {
  app.use(morgan(env.NODE_ENV === "production" ? "combined" : "dev"));
}

app.use(
  "/api",
  rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 500,
    standardHeaders: "draft-8",
    legacyHeaders: false,
    message: {
      ok: false,
      message:
        "Demasiadas solicitudes. Intenta nuevamente más tarde.",
    },
  })
);

app.use("/api", router);

app.use(notFoundMiddleware);
app.use(errorMiddleware);
