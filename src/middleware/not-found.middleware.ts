import type { Request, Response } from "express";

export function notFoundMiddleware(
  req: Request,
  res: Response
): void {
  res.status(404).json({
    ok: false,
    message: `Ruta no encontrada: ${req.method} ${req.originalUrl}`,
  });
}
