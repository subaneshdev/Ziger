package com.zigger.backend.controller;

import com.zigger.backend.dto.RefineRequest;
import com.zigger.backend.dto.RefineResponse;
import com.zigger.backend.model.Task;
import com.zigger.backend.service.AiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/ai")
@CrossOrigin(origins = "*")
public class AiController {

    @Autowired
    private AiService aiService;

    @PostMapping("/refine")
    public ResponseEntity<RefineResponse> refineDescription(@RequestBody RefineRequest request) {
        return ResponseEntity.ok(aiService.refineText(request));
    }

    @GetMapping("/recommendations")
    public ResponseEntity<List<Task>> getRecommendations(@RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(aiService.getRecommendations(userId));
    }
}
