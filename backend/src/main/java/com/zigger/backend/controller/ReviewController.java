package com.zigger.backend.controller;

import com.zigger.backend.model.Review;
import com.zigger.backend.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
@CrossOrigin(origins = "*")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @PostMapping("/{taskId}")
    public ResponseEntity<Review> submitReview(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID taskId,
            @RequestBody Map<String, Object> body) {
        
        try {
            int rating = (int) body.get("rating");
            String comment = (String) body.get("comment");
            return ResponseEntity.ok(reviewService.submitReview(userId, taskId, rating, comment));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Review>> getUserReviews(@PathVariable UUID userId) {
        return ResponseEntity.ok(reviewService.getReviewsForUser(userId));
    }
}
