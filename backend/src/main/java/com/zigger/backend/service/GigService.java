package com.zigger.backend.service;

import com.zigger.backend.dto.GigRequest;
import com.zigger.backend.model.Profile;
import com.zigger.backend.model.Task;
import com.zigger.backend.repository.ProfileRepository;
import com.zigger.backend.repository.TaskRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.UUID;

import com.zigger.backend.model.TaskApplication;
import com.zigger.backend.repository.TaskApplicationRepository;
import java.util.List;
import java.time.OffsetDateTime;
import com.zigger.backend.service.WalletService;
import jakarta.transaction.Transactional;

@Service
public class GigService {

     @Autowired
     private TaskRepository taskRepository;

     @Autowired
     private ProfileRepository profileRepository;

     @Autowired
     private TaskApplicationRepository taskApplicationRepository;

     @Autowired
     private WalletService walletService;

     @Transactional
     public Task createGig(UUID employerId, GigRequest request) {
          Profile employer = profileRepository.findById(employerId)
                    .orElseThrow(() -> new RuntimeException("Employer not found"));

          if (!"employer".equalsIgnoreCase(employer.getRole()) && !"admin".equalsIgnoreCase(employer.getRole())) {
               throw new RuntimeException("Only employers can post gigs");
          }

          // if (!"approved".equals(employer.getKycStatus())) {
          // throw new RuntimeException("KYC verification required to post gigs");
          // }

          Task task = new Task();
          task.setTitle(request.getTitle());
          task.setDescription(request.getDescription());
          task.setLocationName(request.getLocationName());
          task.setGeoLat(request.getGeoLat());
          task.setGeoLng(request.getGeoLng());
          task.setPayout(request.getPayout());
          task.setStartTime(request.getStartTime());
          task.setEndTime(request.getEndTime());
          task.setEstimatedHours(request.getEstimatedHours());
          task.setCreatedBy(employer);
          task.setStatus("open");

          task = taskRepository.save(task);

          // Lock Funds (Transactional will rollback task save if this fails)
          walletService.lockFundsForTask(employerId, task);

          return task;
     }

     public List<Task> getNearbyGigs(double lat, double lng, double radiusKm) {
          return taskRepository.findNearbyTasks(lat, lng, radiusKm);
     }

     public List<Task> getGigsByEmployer(UUID employerId) {
          return taskRepository.findByCreatedBy_Id(employerId);
     }

     public TaskApplication applyForGig(UUID workerId, UUID gigId) {
          Profile worker = profileRepository.findById(workerId)
                    .orElseThrow(() -> new RuntimeException("Worker not found"));

          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!"worker".equalsIgnoreCase(worker.getRole())) {
               throw new RuntimeException("Only workers can apply for gigs");
          }

          // if (!"approved".equals(worker.getKycStatus())) {
          // throw new RuntimeException("KYC verification required to apply for gigs");
          // }

          if (!"open".equals(task.getStatus())) {
               throw new RuntimeException("Gig is not open for applications");
          }

          if (taskApplicationRepository.findByTask_IdAndWorker_Id(gigId, workerId).isPresent()) {
               throw new RuntimeException("Already applied for this gig");
          }

          TaskApplication application = new TaskApplication();
          application.setTask(task);
          application.setWorker(worker);
          application.setStatus("pending");
          // Bid amount could be dynamic, defaulting to null/fixed for MVP

          // Bid amount could be dynamic, defaulting to null/fixed for MVP

          return taskApplicationRepository.save(application);
     }

     public java.util.Optional<TaskApplication> getMyApplication(UUID gigId, UUID workerId) {
          return taskApplicationRepository.findByTask_IdAndWorker_Id(gigId, workerId);
     }

     public List<TaskApplication> getApplicationsForGig(UUID gigId, UUID employerId) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!employerId.equals(task.getCreatedBy().getId())) {
               throw new RuntimeException("Not authorized to view applications for this gig");
          }

          return taskApplicationRepository.findByTask_Id(gigId);
     }

     @Autowired
     private NotificationService notificationService;

     @Transactional
     public Task assignWorker(UUID employerId, UUID gigId, UUID workerId) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!employerId.equals(task.getCreatedBy().getId())) {
               throw new RuntimeException("Not authorized");
          }

          if (!"open".equals(task.getStatus())) {
               throw new RuntimeException("Gig is not open");
          }

          Profile worker = profileRepository.findById(workerId)
                    .orElseThrow(() -> new RuntimeException("Worker not found"));

          task.setAssignedTo(worker);
          task.setStatus("assigned");

          Task savedTask = taskRepository.save(task);

          // Send Notification to Worker
          notificationService.sendNotification(
                    workerId,
                    "You're Hired!",
                    "Congratulations! You have been hired for the gig: " + task.getTitle());

          return savedTask;
     }

     public Task startGig(UUID workerId, UUID gigId, String checkInPhotoUrl) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!workerId.equals(task.getAssignedTo().getId())) {
               throw new RuntimeException("You are not assigned to this gig");
          }

          if (!"assigned".equals(task.getStatus())) {
               // Allow restart if in_progress? For now, strict check.
               if (!"in_progress".equals(task.getStatus()))
                    throw new RuntimeException("Gig must be in 'assigned' state to start");
          }

          task.setStatus("in_progress");
          if (task.getActualStartTime() == null) {
               task.setActualStartTime(OffsetDateTime.now());
          }
          if (checkInPhotoUrl != null) {
               task.setCheckInPhotoUrl(checkInPhotoUrl);
          }

          return taskRepository.save(task);
     }

     public Task uploadProof(UUID workerId, UUID gigId, String photoUrl) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!workerId.equals(task.getAssignedTo().getId())) {
               throw new RuntimeException("Not authorized");
          }

          task.setProofPhotoUrl(photoUrl); // Keeps latest update
          return taskRepository.save(task);
     }

     @Transactional
     public Task completeGig(UUID workerId, UUID gigId, String checkOutPhotoUrl) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!workerId.equals(task.getAssignedTo().getId())) {
               throw new RuntimeException("Not authorized");
          }

          task.setStatus("completed");
          task.setActualEndTime(OffsetDateTime.now());
          if (checkOutPhotoUrl != null) {
               task.setCheckOutPhotoUrl(checkOutPhotoUrl);
          }

          task = taskRepository.save(task);

          // Release Funds
          walletService.releaseFundsToWorker(task);

          return task;
     }

     @Transactional
     public Task cancelGig(UUID employerId, UUID gigId) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!employerId.equals(task.getCreatedBy().getId())) {
               throw new RuntimeException("Not authorized");
          }

          if ("completed".equals(task.getStatus()) || "in_progress".equals(task.getStatus())) {
               throw new RuntimeException("Cannot cancel gig in progress or completed");
          }

          task.setStatus("cancelled");
          task = taskRepository.save(task);

          // Refund Employer
          walletService.refundToEmployer(task);

          return task;
     }

     public List<Task> getAssignedGigs(UUID workerId) {
          return taskRepository.findByAssignedTo_Id(workerId);
     }
}
