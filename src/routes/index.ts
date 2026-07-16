import { Router } from "express";
import { pool } from "../config/database";

export const router = Router();

router.get("/health", async (_req, res) => {
  await pool.query("SELECT 1");

  res.status(200).json({
    ok: true,
    message: "Bakery System API funcionando",
    database: "connected",
    timestamp: new Date().toISOString(),
  });
});
