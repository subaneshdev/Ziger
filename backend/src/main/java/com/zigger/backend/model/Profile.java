package com.zigger.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Profile {

    @Id
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(unique = true)
    private String mobile;

    private String role; // worker, employer, admin

    @Column(name = "full_name")
    private String fullName;

    private String email;

    @Column(name = "wallet_balance")
    private BigDecimal walletBalance;

    @Column(name = "trust_score")
    private Integer trustScore;

    @Column(name = "kyc_status")
    private String kycStatus; // pending, approved, rejected

    private LocalDate dob;
    private String gender;

    @Column(name = "profile_photo_url")
    private String profilePhotoUrl;

    private String address;
    private String city;
    private String state;
    private String pincode;

    @Column(name = "id_type")
    private String idType;

    @Column(name = "id_card_number")
    private String idCardNumber;

    @Column(name = "id_card_front_url")
    private String idCardFrontUrl;

    @Column(name = "id_card_back_url")
    private String idCardBackUrl;

    @Column(name = "selfie_url")
    private String selfieUrl;

    @Column(name = "current_lat")
    private Double currentLat;

    @Column(name = "current_lng")
    private Double currentLng;

    @Column(name = "last_location_update")
    private java.time.OffsetDateTime lastLocationUpdate;

    // --- Gig Worker KYC Fields ---
    @Column(name = "bank_account_name")
    private String bankAccountName;

    @Column(name = "bank_account_number")
    private String bankAccountNumber;

    @Column(name = "bank_ifsc")
    private String bankIfsc;

    @Column(name = "upi_id")
    private String upiId;

    @Column(name = "gig_types", columnDefinition = "TEXT")
    private String gigTypes; // JSON or Comma Separated

    @Column(name = "work_radius")
    private Double workRadius;

    @Column(name = "available_time_slots")
    private String availableTimeSlots;

    @Column(name = "willing_to_travel")
    private Boolean willingToTravel;

    // --- Employer KYC Fields ---
    @Column(name = "employer_type")
    private String employerType; // Individual, Small Business, Company

    @Column(name = "business_name")
    private String businessName;

    @Column(name = "nature_of_work")
    private String natureOfWork;

    @Column(name = "business_address")
    private String businessAddress;

    @Column(name = "billing_name")
    private String billingName;

    @Column(name = "gst_number")
    private String gstNumber;

    @Column(name = "payment_method")
    private String paymentMethod; // UPI, Card, Net Banking

    @Column(name = "invoice_address")
    private String invoiceAddress;

    @Column(name = "is_agreed_to_terms")
    private Boolean isAgreedToTerms;
}
