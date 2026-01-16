package com.zigger.backend.controller;

import com.zigger.backend.model.Profile;
import com.zigger.backend.model.Task;
import com.zigger.backend.model.WalletTransaction;
import com.zigger.backend.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private AdminService adminService;

    // Existing KYC endpoints are in AdminKycController, these are general admin ops

    @GetMapping("/users")
    public ResponseEntity<List<Profile>> getAllUsers() {
        return ResponseEntity.ok(adminService.getAllUsers());
    }

    @GetMapping("/gigs")
    public ResponseEntity<List<Task>> getAllGigs() {
        return ResponseEntity.ok(adminService.getAllGigs());
    }

    @GetMapping("/transactions")
    public ResponseEntity<List<WalletTransaction>> getAllTransactions() {
        return ResponseEntity.ok(adminService.getAllTransactions());
    }
}
