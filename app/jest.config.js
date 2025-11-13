module.exports = {
  testEnvironment: "node",
  coverageDirectory: "coverage",
  collectCoverageFrom: ["*.js", "!jest.config.js"],
  testMatch: ["**/*.test.js"],
  verbose: true,
};
