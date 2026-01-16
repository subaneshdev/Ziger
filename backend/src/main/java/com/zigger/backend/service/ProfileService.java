package com.zigger.backend.service;

import com.zigger.backend.dto.KycRequest;
import com.zigger.backend.model.Profile;
import com.zigger.backend.repository.ProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

@Service
public class ProfileService {

    @Autowired
    private ProfileRepository profileRepository;

    public Optional<Profile> getProfileById(UUID id) {
        return profileRepository.findById(id);
    }

    public Profile getProfile(UUID id) {
        return profileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
    }

    public Optional<Profile> getProfileByMobile(String mobile) {
        return profileRepository.findByMobile(mobile);
    }

    public Profile saveProfile(Profile profile) {
        return profileRepository.save(profile);
    }

    public Profile submitKyc(UUID profileId, KycRequest kycData) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        profile.setFullName(kycData.getFullName());
        profile.setDob(kycData.getDob());
        profile.setGender(kycData.getGender());
        profile.setAddress(kycData.getAddress());
        profile.setCity(kycData.getCity());
        profile.setState(kycData.getState());
        profile.setPincode(kycData.getPincode());

        profile.setIdType(kycData.getIdType());
        profile.setIdCardNumber(kycData.getIdCardNumber());
        profile.setIdCardFrontUrl(kycData.getIdCardFrontUrl());
        profile.setIdCardBackUrl(kycData.getIdCardBackUrl());
        profile.setSelfieUrl(kycData.getSelfieUrl());

        // --- Worker Fields ---
        if (kycData.getBankAccountName() != null)
            profile.setBankAccountName(kycData.getBankAccountName());
        if (kycData.getBankAccountNumber() != null)
            profile.setBankAccountNumber(kycData.getBankAccountNumber());
        if (kycData.getBankIfsc() != null)
            profile.setBankIfsc(kycData.getBankIfsc());
        if (kycData.getUpiId() != null)
            profile.setUpiId(kycData.getUpiId());

        if (kycData.getGigTypes() != null) {
            profile.setGigTypes(String.join(",", kycData.getGigTypes()));
        }
        if (kycData.getWorkRadius() != null)
            profile.setWorkRadius(kycData.getWorkRadius());
        if (kycData.getAvailableTimeSlots() != null)
            profile.setAvailableTimeSlots(kycData.getAvailableTimeSlots());
        if (kycData.getWillingToTravel() != null)
            profile.setWillingToTravel(kycData.getWillingToTravel());

        // --- Employer Fields ---
        if (kycData.getEmployerType() != null)
            profile.setEmployerType(kycData.getEmployerType());
        if (kycData.getBusinessName() != null)
            profile.setBusinessName(kycData.getBusinessName());
        if (kycData.getNatureOfWork() != null)
            profile.setNatureOfWork(kycData.getNatureOfWork());
        if (kycData.getBusinessAddress() != null)
            profile.setBusinessAddress(kycData.getBusinessAddress());

        if (kycData.getBillingName() != null)
            profile.setBillingName(kycData.getBillingName());
        if (kycData.getGstNumber() != null)
            profile.setGstNumber(kycData.getGstNumber());
        if (kycData.getPaymentMethod() != null)
            profile.setPaymentMethod(kycData.getPaymentMethod());
        if (kycData.getInvoiceAddress() != null)
            profile.setInvoiceAddress(kycData.getInvoiceAddress());
        if (kycData.getIsAgreedToTerms() != null)
            profile.setIsAgreedToTerms(kycData.getIsAgreedToTerms());

        profile.setKycStatus("pending"); // Update status to pending review

        return profileRepository.save(profile);
    }

    public java.util.List<Profile> getPendingKycProfiles() {
        return profileRepository.findByKycStatus("pending");
    }

    public Profile adjudicateKyc(UUID profileId, String status, String reason) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        if (!status.equals("approved") && !status.equals("rejected")) {
            throw new IllegalArgumentException("Invalid status. Must be 'approved' or 'rejected'");
        }

        profile.setKycStatus(status);
        // In a real app, store rejection reason in a separate table or notification log

        return profileRepository.save(profile);
    }

    public void updateLocation(UUID userId, Double lat, Double lng) {
        Profile profile = profileRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        profile.setCurrentLat(lat);
        profile.setCurrentLng(lng);
        profile.setLastLocationUpdate(java.time.OffsetDateTime.now());

        profileRepository.save(profile);
    }

    public Profile updateRole(UUID profileId, String role) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        profile.setRole(role);
        return profileRepository.save(profile);
    }
}
