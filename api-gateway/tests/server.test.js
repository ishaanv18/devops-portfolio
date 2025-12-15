const request = require('supertest');
const app = require('../server');

describe('API Gateway Tests', () => {

    describe('Health Check', () => {
        it('should return health status', async () => {
            const response = await request(app).get('/health');
            expect(response.status).toBe(200);
            expect(response.body.status).toBe('UP');
            expect(response.body.service).toBe('api-gateway');
        });
    });

    describe('Metrics Endpoint', () => {
        it('should return Prometheus metrics', async () => {
            const response = await request(app).get('/metrics');
            expect(response.status).toBe(200);
            expect(response.text).toContain('gateway_http_requests_total');
        });
    });

    describe('404 Handler', () => {
        it('should return 404 for unknown routes', async () => {
            const response = await request(app).get('/unknown-route');
            expect(response.status).toBe(404);
            expect(response.body.error).toBe('Route not found');
        });
    });
});
