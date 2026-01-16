package com.zigger.backend.controller;

import com.zigger.backend.model.Notification;
import com.zigger.backend.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<Notification>> getNotifications(@RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(notificationService.getMyNotifications(userId));
    }
}
