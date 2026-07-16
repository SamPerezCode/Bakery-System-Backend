import type {
  ErrorRequestHandler,
  NextFunction,
  Request,
  Response,
} from "express";
import { ZodError } from "zod";
import { env } from "../config/env";
import { AppError } from "../utils/app-error";

export const errorMiddleware: ErrorRequestHandler = (
  error: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction
): void => {
  if (error instanceof ZodError) {
    res.status(400).json({
      ok: false,
      message: "Datos de entrada inválidos",
      errors: error.issues,
    });
    return;
  }

  if (error instanceof AppError) {
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
    ...(env.NODE_ENV === "development" && error instanceof Error
      ? { error: error.message, stack: error.stack }
      : {}),
  });
};
