package com.zigger.backend.controller;

import com.zigger.backend.dto.AuthResponse;
import com.zigger.backend.dto.OtpRequest;
import com.zigger.backend.dto.OtpVerifyRequest;
import com.zigger.backend.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/send-otp")
    public ResponseEntity<String> sendOtp(@RequestBody OtpRequest request) {
        String response = authService.sendOtp(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<AuthResponse> verifyOtp(@RequestBody OtpVerifyRequest request) {
        try {
            AuthResponse response = authService.verifyOtp(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            e.printStackTrace(); 
            return ResponseEntity.badRequest().build();
        }
    }
}
