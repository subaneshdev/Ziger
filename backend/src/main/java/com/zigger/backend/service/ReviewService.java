package com.zigger.backend.service;

import com.zigger.backend.model.Profile;
import com.zigger.backend.model.Review;
import com.zigger.backend.model.Task;
import com.zigger.backend.repository.ProfileRepository;
import com.zigger.backend.repository.ReviewRepository;
import com.zigger.backend.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private TaskRepository taskRepository;

    @Autowired
    private ProfileRepository profileRepository;

    public Review submitReview(UUID reviewerId, UUID taskId, int rating, String comment) {
        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        if (!"completed".equals(task.getStatus())) {
            throw new RuntimeException("Can only review completed tasks");
        }

        Profile reviewer = profileRepository.findById(reviewerId)
                .orElseThrow(() -> new RuntimeException("Reviewer not found"));

        // Determine reviewee (if reviewer is worker, reviewee is employer, and vice-versa)
        Profile reviewee;
        if (reviewer.getId().equals(task.getAssignedTo().getId())) {
             reviewee = task.getCreatedBy();
        } else if (reviewer.getId().equals(task.getCreatedBy().getId())) {
             reviewee = task.getAssignedTo();
        } else {
             throw new RuntimeException("Not a participant in this task");
        }

        Review review = new Review();
        review.setTask(task);
        review.setReviewer(reviewer);
        review.setReviewee(reviewee);
        review.setRating(rating);
        review.setComment(comment);
        
        return reviewRepository.save(review);
    }

    public List<Review> getReviewsForUser(UUID userId) {
        return reviewRepository.findByReviewee_Id(userId);
    }
}
