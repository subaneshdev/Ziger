package com.zigger.backend.service;

import com.zigger.backend.dto.RefineRequest;
import com.zigger.backend.dto.RefineResponse;
import com.zigger.backend.model.Task;
import com.zigger.backend.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Service
public class AiService {

    @Autowired
    private TaskRepository taskRepository;

    public RefineResponse refineText(RefineRequest request) {
        String original = request.getText();
        String refined = original;

        // Mock AI Logic
        if (original != null && !original.isEmpty()) {
            if (original.length() < 20) {
                 refined = "Looking for a professional to " + original.toLowerCase() + ". Great pay and friendly environment. Verified experience required.";
            } else {
                 refined = "✨ Professionally Refined: " + original + " Ensure safety protocols are followed and enjoy working with a top-rated team.";
            }
        }

        return RefineResponse.builder().refinedText(refined).build();
    }

    public List<Task> getRecommendations(UUID workerId) {
        // Mock Recommendation Logic
        // In real app: analyze worker history, skills, etc.
        // MVP: Return random open tasks or tasks matching a hardcoded category
        
        // Let's return all open tasks for now as "Recommendations"
        // or filter by a "General" category if we had one.
        
        List<Task> openTasks = taskRepository.findByStatus("open");
        // Limit to 5
        if (openTasks.size() > 5) {
            return openTasks.subList(0, 5);
        }
        return openTasks;
    }
}
