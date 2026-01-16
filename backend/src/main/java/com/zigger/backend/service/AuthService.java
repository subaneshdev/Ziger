package com.zigger.backend.service;

import com.zigger.backend.dto.AuthResponse;
import com.zigger.backend.dto.OtpRequest;
import com.zigger.backend.dto.OtpVerifyRequest;
import com.zigger.backend.model.Profile;
import com.zigger.backend.repository.ProfileRepository;
import com.zigger.backend.security.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private JwtUtil jwtUtil;

    // In-memory OTP store for MVP (Use Redis in production)
    private final ConcurrentHashMap<String, String> otpStore = new ConcurrentHashMap<>();

    public String sendOtp(OtpRequest request) {
        String mobile = request.getMobile();
        // Mock OTP generation
        String otp = "123456"; 
        otpStore.put(mobile, otp);
        
        logger.info("OTP sent to: {}", mobile);
        logger.debug("OTP for {}: {}", mobile, otp); // Only in debug
        return "OTP sent successfully";
    }

    public AuthResponse verifyOtp(OtpVerifyRequest request) {
        String mobile = request.getMobile();
        String otp = request.getOtp();

        if (otpStore.containsKey(mobile) && otpStore.get(mobile).equals(otp)) {
            otpStore.remove(mobile); // Clear OTP after use

            // Check if user exists
            Optional<Profile> existingProfile = profileRepository.findByMobile(mobile);
            Profile profile;

            if (existingProfile.isPresent()) {
                profile = existingProfile.get();
            } else {
                // Register new user
                try {
                    profile = new Profile();
                    profile.setId(UUID.randomUUID());
                    profile.setMobile(mobile);
                    profile.setRole("user"); // Default role, user selects later
                    profile.setKycStatus("not_started");
                    profile.setWalletBalance(BigDecimal.ZERO);
                    profile.setTrustScore(100); 
                    logger.info("Attempting to save profile: {}", profile);
                    profile = profileRepository.save(profile);
                    logger.info("Profile saved successfully: {}", profile.getId());
                } catch (Exception e) {
                    logger.error("Error saving profile: ", e);
                    throw new RuntimeException("Error saving profile: " + e.getMessage());
                }
            }

            // Generate Token
            try {
                String token = jwtUtil.generateToken(mobile, profile.getRole());
                logger.info("Token generated successfully");
                
                return AuthResponse.builder()
                        .accessToken(token)
                        .refreshToken(token) // Simplified for MVP
                        .profile(profile)
                        .build();
            } catch (Exception e) {
                logger.error("Error generating token: ", e);
                throw new RuntimeException("Error generating token: " + e.getMessage());
            }
        } else {
            logger.warn("Invalid OTP provided: {}", request.getOtp());
            throw new RuntimeException("Invalid OTP");
        }
    }
}
