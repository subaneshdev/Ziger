package com.zigger.backend.controller;

import com.zigger.backend.dto.KycRequest;
import com.zigger.backend.model.Profile;
import com.zigger.backend.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @GetMapping("/{id}")
    public ResponseEntity<Profile> getProfile(@PathVariable UUID id) {
        return ResponseEntity.ok(profileService.getProfile(id));
    }

    @PostMapping("/{id}/kyc")
    public ResponseEntity<Profile> submitKyc(@PathVariable UUID id, @RequestBody KycRequest kycData) {
        return ResponseEntity.ok(profileService.submitKyc(id, kycData));
    }

    @PutMapping("/{id}/role")
    public ResponseEntity<Profile> updateRole(@PathVariable UUID id, @RequestBody Map<String, String> payload) {
        String role = payload.get("role");
        return ResponseEntity.ok(profileService.updateRole(id, role));
    }
}
