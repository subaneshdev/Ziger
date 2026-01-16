package com.zigger.backend.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class KycRequest {
    // Step 1: Basics
    private String fullName;
    private LocalDate dob;
    private String gender;
    private String address;
    private String city;
    private String state;
    private String pincode;

    // Step 2: Identity
    private String idType;
    private String idCardNumber;
    private String idCardFrontUrl;
    private String idCardBackUrl;
    private String selfieUrl;

    // Step 3: Bank (Worker)
    private String bankAccountName;
    private String bankAccountNumber;
    private String bankIfsc;
    private String upiId;

    // Step 4: Work Preferences (Worker)
    // We can accept a List<String> and join it, or just String. Let's do List for
    // cleaner API if JSON mapping works,
    // but for simplicity with existing "String gigTypes" in Entity, let's accept
    // String or modify logic in Service.
    // Let's accept List<String> here and join in Service.
    private java.util.List<String> gigTypes;
    private Double workRadius;
    private String availableTimeSlots;
    private Boolean willingToTravel;

    // --- Employer Fields ---
    private String employerType;
    private String businessName;
    private String natureOfWork;
    private String businessAddress;

    private String billingName;
    private String gstNumber;
    private String paymentMethod;
    private String invoiceAddress;

    private Boolean isAgreedToTerms;
}
