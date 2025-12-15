package com.devops.productservice.controller;

import com.devops.productservice.model.Product;
import com.devops.productservice.repository.ProductRepository;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductRepository productRepository;

    private final Counter productCreatedCounter;
    private final Counter productRequestCounter;

    public ProductController(MeterRegistry meterRegistry) {
        this.productCreatedCounter = Counter.builder("products_created_total")
                .description("Total number of products created")
                .register(meterRegistry);

        this.productRequestCounter = Counter.builder("product_requests_total")
                .description("Total number of product API requests")
                .register(meterRegistry);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "product-service");
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        productRequestCounter.increment();
        return ResponseEntity.ok(productRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        productRequestCounter.increment();
        return productRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String name) {
        productRequestCounter.increment();
        return ResponseEntity.ok(productRepository.findByNameContainingIgnoreCase(name));
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        productRequestCounter.increment();
        Product savedProduct = productRepository.save(product);
        productCreatedCounter.increment();
        return ResponseEntity.status(HttpStatus.CREATED).body(savedProduct);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id, @RequestBody Product productDetails) {
        productRequestCounter.increment();
        return productRepository.findById(id)
                .map(product -> {
                    product.setName(productDetails.getName());
                    product.setDescription(productDetails.getDescription());
                    product.setPrice(productDetails.getPrice());
                    product.setStock(productDetails.getStock());
                    return ResponseEntity.ok(productRepository.save(product));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productRequestCounter.increment();
        return productRepository.findById(id)
                .map(product -> {
                    productRepository.delete(product);
                    return ResponseEntity.ok().<Void>build();
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
