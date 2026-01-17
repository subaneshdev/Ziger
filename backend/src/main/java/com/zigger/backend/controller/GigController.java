package com.zigger.backend.controller;

import com.zigger.backend.dto.GigRequest;
import com.zigger.backend.model.Task;
import com.zigger.backend.service.GigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

import com.zigger.backend.model.TaskApplication;
import java.util.List;

@RestController
@RequestMapping("/api/gigs")
@CrossOrigin(origins = "*")
public class GigController {

    @Autowired
    private GigService gigService;

    // Ideally, employerId should be extracted from JWT Token (SecurityContext)
    // For MVP/Demostration, we accept it as a param or path variable, 
    // but clearly this should be secured in production.
    @PostMapping
    public ResponseEntity<Task> createGig(
            @RequestHeader("X-User-Id") UUID userId, 
            @RequestBody GigRequest request) {
        
        try {
            Task createdTask = gigService.createGig(userId, request);
            return ResponseEntity.ok(createdTask);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/feed")
    public ResponseEntity<List<Task>> getFeed(
            @RequestParam double lat, 
            @RequestParam double lng, 
            @RequestParam(defaultValue = "10") double radius) {
        
        return ResponseEntity.ok(gigService.getNearbyGigs(lat, lng, radius));
    }

    @GetMapping("/my-gigs")
    public ResponseEntity<List<Task>> getMyGigs(@RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(gigService.getGigsByEmployer(userId));
    }

    @PostMapping("/{gigId}/apply")
    public ResponseEntity<TaskApplication> applyForGig(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID gigId) {
        
        try {
            TaskApplication application = gigService.applyForGig(userId, gigId);
            return ResponseEntity.ok(application);
        } catch (RuntimeException e) {
             return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{gigId}/applications")
    public ResponseEntity<List<TaskApplication>> getGigApplications(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID gigId) {
        try {
            return ResponseEntity.ok(gigService.getApplicationsForGig(gigId, userId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{gigId}/assign/{workerId}")
    public ResponseEntity<Task> assignWorker(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID gigId,
            @PathVariable UUID workerId) {
        try {
            return ResponseEntity.ok(gigService.assignWorker(userId, gigId, workerId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{gigId}/start")
    public ResponseEntity<Task> startGig(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID gigId) {
        try {
            return ResponseEntity.ok(gigService.startGig(userId, gigId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{gigId}/proof")
    public ResponseEntity<Task> uploadProof(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID gigId,
            @RequestBody String photoUrl) {
        try {
            return ResponseEntity.ok(gigService.uploadProof(userId, gigId, photoUrl));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/{gigId}/complete")
    public ResponseEntity<Task> completeGig(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID gigId) {
        try {
            return ResponseEntity.ok(gigService.completeGig(userId, gigId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }

    }

    @DeleteMapping("/{gigId}")
    public ResponseEntity<Task> cancelGig(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID gigId) {
        try {
            return ResponseEntity.ok(gigService.cancelGig(userId, gigId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
