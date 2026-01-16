package com.zigger.backend.controller;

import com.zigger.backend.dto.KycAdjudicationRequest;
import com.zigger.backend.model.Profile;
import com.zigger.backend.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/kyc")
@CrossOrigin(origins = "*")
public class AdminKycController {

    @Autowired
    private ProfileService profileService;

    @GetMapping("/pending")
    public ResponseEntity<List<Profile>> getPendingKyc() {
        return ResponseEntity.ok(profileService.getPendingKycProfiles());
    }

    @PostMapping("/{userId}/adjudicate")
    public ResponseEntity<Profile> adjudicateKyc(
            @PathVariable UUID userId,
            @RequestBody KycAdjudicationRequest request) {
        
        try {
            Profile updatedProfile = profileService.adjudicateKyc(
                    userId, 
                    request.getStatus(), 
                    request.getRejectionReason()
            );
            return ResponseEntity.ok(updatedProfile);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
