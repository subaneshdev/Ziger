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
import com.zigger.backend.exception.GigException;
import org.springframework.http.HttpStatus;
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
               throw new GigException("Only employers can post gigs", "NOT_AUTHORIZED", HttpStatus.FORBIDDEN);
          }

          // if (!"approved".equals(employer.getKycStatus())) {
          // throw new GigException("KYC verification required to post gigs",
          // "NOT_VERIFIED", HttpStatus.FORBIDDEN);
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

     public List<Task> getAllOpenGigs() {
          return taskRepository.findByStatus("open");
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
               throw new GigException("Only workers can apply for gigs", "NOT_AUTHORIZED", HttpStatus.FORBIDDEN);
          }

          // if (!"approved".equals(worker.getKycStatus())) {
          // throw new GigException("KYC verification required to apply for gigs",
          // "NOT_VERIFIED", HttpStatus.FORBIDDEN);
          // }

          if (!"open".equals(task.getStatus())) {
               throw new GigException("Gig is not open for applications", "GIG_CLOSED", HttpStatus.BAD_REQUEST);
          }

          if (taskApplicationRepository.findByTaskIdAndWorkerId(gigId, workerId).isPresent()) {
               throw new GigException("Already applied for this gig", "ALREADY_APPLIED", HttpStatus.CONFLICT);
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
          return taskApplicationRepository.findByTaskIdAndWorkerId(gigId, workerId);
     }

     public List<TaskApplication> getApplicationsForGig(UUID gigId, UUID employerId) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!employerId.equals(task.getCreatedBy().getId())) {
               throw new RuntimeException("Not authorized to view applications for this gig");
          }

          return taskApplicationRepository.findByTaskId(gigId);
     }

     @Autowired
     private NotificationService notificationService;

     @Transactional
     public Task assignWorker(UUID employerId, UUID gigId, UUID workerId) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!employerId.equals(task.getCreatedBy().getId())) {
               throw new GigException("Not authorized", "NOT_AUTHORIZED", HttpStatus.FORBIDDEN);
          }

          if (!"open".equals(task.getStatus())) {
               throw new GigException("Gig is not open", "GIG_CLOSED", HttpStatus.BAD_REQUEST);
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

          // Send Notification to Employer
          notificationService.sendNotification(
                    employerId,
                    "Worker Assigned Successfully",
                    "You have assigned " + worker.getFullName() + " for " + task.getTitle()
                              + ". You can now chat with them.");

          return savedTask;
     }

     public Task startGig(UUID workerId, UUID gigId) {
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

          return taskRepository.save(task);
     }

     public Task uploadProof(UUID workerId, UUID gigId, String photoUrl) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!workerId.equals(task.getAssignedTo().getId())) {
               throw new RuntimeException("Not authorized");
          }

          task.setProofPhotoUrl(photoUrl);
          task.getInProgressPhotos().add(photoUrl); // Append to history
          return taskRepository.save(task);
     }

     @Transactional
     public void updateGigLocation(UUID gigId, double lat, double lng) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          task.setLiveLat(lat);
          task.setLiveLng(lng);
          task.setLastUpdated(OffsetDateTime.now());

          taskRepository.save(task);
     }

     public Task completeGig(UUID workerId, UUID gigId) {
          Task task = taskRepository.findById(gigId)
                    .orElseThrow(() -> new RuntimeException("Gig not found"));

          if (!workerId.equals(task.getAssignedTo().getId())) {
               throw new RuntimeException("Not authorized");
          }

          task.setStatus("completed");
          task.setActualEndTime(OffsetDateTime.now());
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
