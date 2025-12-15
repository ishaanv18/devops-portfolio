const express = require('express');
const axios = require('axios');
const router = express.Router();

// Service URLs - can be overridden by environment variables
const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:8081';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://localhost:8082';

// Axios timeout configuration
const axiosConfig = {
    timeout: 5000,
    headers: {
        'Content-Type': 'application/json'
    }
};

// ============ User Service Routes ============

// Get all users
router.get('/users', async (req, res) => {
    try {
        const response = await axios.get(`${USER_SERVICE_URL}/api/users`, axiosConfig);
        res.json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'User Service');
    }
});

// Get user by ID
router.get('/users/:id', async (req, res) => {
    try {
        const response = await axios.get(`${USER_SERVICE_URL}/api/users/${req.params.id}`, axiosConfig);
        res.json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'User Service');
    }
});

// Create user
router.post('/users', async (req, res) => {
    try {
        const response = await axios.post(`${USER_SERVICE_URL}/api/users`, req.body, axiosConfig);
        res.status(201).json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'User Service');
    }
});

// Update user
router.put('/users/:id', async (req, res) => {
    try {
        const response = await axios.put(`${USER_SERVICE_URL}/api/users/${req.params.id}`, req.body, axiosConfig);
        res.json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'User Service');
    }
});

// Delete user
router.delete('/users/:id', async (req, res) => {
    try {
        await axios.delete(`${USER_SERVICE_URL}/api/users/${req.params.id}`, axiosConfig);
        res.status(204).send();
    } catch (error) {
        handleServiceError(error, res, 'User Service');
    }
});

// ============ Product Service Routes ============

// Get all products
router.get('/products', async (req, res) => {
    try {
        const response = await axios.get(`${PRODUCT_SERVICE_URL}/api/products`, axiosConfig);
        res.json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'Product Service');
    }
});

// Get product by ID
router.get('/products/:id', async (req, res) => {
    try {
        const response = await axios.get(`${PRODUCT_SERVICE_URL}/api/products/${req.params.id}`, axiosConfig);
        res.json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'Product Service');
    }
});

// Search products
router.get('/products/search', async (req, res) => {
    try {
        const response = await axios.get(`${PRODUCT_SERVICE_URL}/api/products/search`, {
            ...axiosConfig,
            params: req.query
        });
        res.json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'Product Service');
    }
});

// Create product
router.post('/products', async (req, res) => {
    try {
        const response = await axios.post(`${PRODUCT_SERVICE_URL}/api/products`, req.body, axiosConfig);
        res.status(201).json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'Product Service');
    }
});

// Update product
router.put('/products/:id', async (req, res) => {
    try {
        const response = await axios.put(`${PRODUCT_SERVICE_URL}/api/products/${req.params.id}`, req.body, axiosConfig);
        res.json(response.data);
    } catch (error) {
        handleServiceError(error, res, 'Product Service');
    }
});

// Delete product
router.delete('/products/:id', async (req, res) => {
    try {
        await axios.delete(`${PRODUCT_SERVICE_URL}/api/products/${req.params.id}`, axiosConfig);
        res.status(204).send();
    } catch (error) {
        handleServiceError(error, res, 'Product Service');
    }
});

// ============ Aggregated Routes ============

// Get user with their activity (example of service aggregation)
router.get('/users/:id/dashboard', async (req, res) => {
    try {
        const [userResponse, productsResponse] = await Promise.all([
            axios.get(`${USER_SERVICE_URL}/api/users/${req.params.id}`, axiosConfig),
            axios.get(`${PRODUCT_SERVICE_URL}/api/products`, axiosConfig)
        ]);

        res.json({
            user: userResponse.data,
            totalProducts: productsResponse.data.length,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        handleServiceError(error, res, 'Aggregation');
    }
});

// Error handler helper
function handleServiceError(error, res, serviceName) {
    console.error(`${serviceName} error:`, error.message);

    if (error.response) {
        // Service responded with error
        res.status(error.response.status).json({
            error: `${serviceName} error`,
            message: error.response.data.message || error.message,
            status: error.response.status
        });
    } else if (error.request) {
        // Service didn't respond
        res.status(503).json({
            error: `${serviceName} unavailable`,
            message: 'Service is not responding'
        });
    } else {
        // Other error
        res.status(500).json({
            error: 'Gateway error',
            message: error.message
        });
    }
}

module.exports = router;
