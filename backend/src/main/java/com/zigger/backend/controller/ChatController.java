package com.zigger.backend.controller;

import com.zigger.backend.model.ChatMessage;
import com.zigger.backend.service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*")
public class ChatController {

    @Autowired
    private ChatService chatService;

    @PostMapping("/{taskId}/send")
    public ResponseEntity<ChatMessage> sendMessage(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID taskId,
            @RequestBody Map<String, String> body) {
        
        try {
            String content = body.get("content");
            if (content == null || content.isEmpty()) {
                throw new RuntimeException("Content cannot be empty");
            }
            return ResponseEntity.ok(chatService.sendMessage(userId, taskId, content));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/{taskId}/messages")
    public ResponseEntity<List<ChatMessage>> getMessages(
            @PathVariable UUID taskId) {
        return ResponseEntity.ok(chatService.getMessages(taskId));
    }
}
