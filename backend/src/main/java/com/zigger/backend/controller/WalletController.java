package com.zigger.backend.controller;

import com.zigger.backend.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/wallet")
@CrossOrigin(origins = "*")
public class WalletController {

    @Autowired
    private WalletService walletService;

    @Autowired
    private com.zigger.backend.repository.ProfileRepository profileRepository;

    @GetMapping("/balance")
    public ResponseEntity<Map<String, BigDecimal>> getBalance(@RequestHeader("X-User-Id") UUID userId) {
        return profileRepository.findById(userId)
                .map(p -> ResponseEntity.ok(Map.of("balance", p.getWalletBalance())))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/transactions")
    public ResponseEntity<java.util.List<com.zigger.backend.model.WalletTransaction>> getTransactions(@RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(walletService.getTransactions(userId));
    }

    // For Demo/Dev: Allow "Fake" deposit to test flow
    @PostMapping("/deposit")
    public ResponseEntity<String> deposit(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestBody Map<String, BigDecimal> request) {
        
        try {
            walletService.deposit(userId, request.get("amount"));
            return ResponseEntity.ok("Deposited successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
