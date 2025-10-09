import axios from "axios";

export const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || "http://localhost:8000",
  headers: { "Content-Type": "application/json" },
  withCredentials: false,
});

// (Later) attach JWT here if/when you add auth tokens
// http.interceptors.request.use((config) => { ...; return config; });
