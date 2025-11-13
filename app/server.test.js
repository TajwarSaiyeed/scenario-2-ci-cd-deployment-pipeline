const request = require("supertest");
const { app, server } = require("./server");

describe("Express App Tests", () => {
  afterAll((done) => {
    server.close(done);
  });

  describe("GET /", () => {
    it("should return welcome message", async () => {
      const response = await request(app).get("/");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("message");
      expect(response.body.message).toBe(
        "Welcome to the Demo CI/CD Application!"
      );
      expect(response.body).toHaveProperty("version");
      expect(response.body).toHaveProperty("timestamp");
    });
  });

  describe("GET /health", () => {
    it("should return health status", async () => {
      const response = await request(app).get("/health");
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("status");
      expect(response.body.status).toBe("healthy");
      expect(response.body).toHaveProperty("uptime");
      expect(response.body).toHaveProperty("timestamp");
    });
  });

  describe("GET /api/hello", () => {
    it("should return hello world message", async () => {
      const response = await request(app).get("/api/hello");
      expect(response.status).toBe(200);
      expect(response.body.message).toBe("Hello, World!");
    });

    it("should return personalized hello message", async () => {
      const response = await request(app).get("/api/hello?name=Jenkins");
      expect(response.status).toBe(200);
      expect(response.body.message).toBe("Hello, Jenkins!");
    });
  });

  describe("GET /nonexistent", () => {
    it("should return 404 for non-existent route", async () => {
      const response = await request(app).get("/nonexistent");
      expect(response.status).toBe(404);
    });
  });
});
