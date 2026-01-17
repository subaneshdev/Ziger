package com.zigger.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "profiles")
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

    public Profile() {
    }

    public Profile(UUID id, String mobile, String role, String fullName, String email, BigDecimal walletBalance,
            Integer trustScore, String kycStatus, LocalDate dob, String gender, String profilePhotoUrl, String address,
            String city, String state, String pincode, String idType, String idCardNumber, String idCardFrontUrl,
            String idCardBackUrl, String selfieUrl, Double currentLat, Double currentLng,
            java.time.OffsetDateTime lastLocationUpdate, String bankAccountName, String bankAccountNumber,
            String bankIfsc, String upiId, String gigTypes, Double workRadius, String availableTimeSlots,
            Boolean willingToTravel, String employerType, String businessName, String natureOfWork,
            String businessAddress, String billingName, String gstNumber, String paymentMethod, String invoiceAddress,
            Boolean isAgreedToTerms) {
        this.id = id;
        this.mobile = mobile;
        this.role = role;
        this.fullName = fullName;
        this.email = email;
        this.walletBalance = walletBalance;
        this.trustScore = trustScore;
        this.kycStatus = kycStatus;
        this.dob = dob;
        this.gender = gender;
        this.profilePhotoUrl = profilePhotoUrl;
        this.address = address;
        this.city = city;
        this.state = state;
        this.pincode = pincode;
        this.idType = idType;
        this.idCardNumber = idCardNumber;
        this.idCardFrontUrl = idCardFrontUrl;
        this.idCardBackUrl = idCardBackUrl;
        this.selfieUrl = selfieUrl;
        this.currentLat = currentLat;
        this.currentLng = currentLng;
        this.lastLocationUpdate = lastLocationUpdate;
        this.bankAccountName = bankAccountName;
        this.bankAccountNumber = bankAccountNumber;
        this.bankIfsc = bankIfsc;
        this.upiId = upiId;
        this.gigTypes = gigTypes;
        this.workRadius = workRadius;
        this.availableTimeSlots = availableTimeSlots;
        this.willingToTravel = willingToTravel;
        this.employerType = employerType;
        this.businessName = businessName;
        this.natureOfWork = natureOfWork;
        this.businessAddress = businessAddress;
        this.billingName = billingName;
        this.gstNumber = gstNumber;
        this.paymentMethod = paymentMethod;
        this.invoiceAddress = invoiceAddress;
        this.isAgreedToTerms = isAgreedToTerms;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public BigDecimal getWalletBalance() {
        return walletBalance;
    }

    public void setWalletBalance(BigDecimal walletBalance) {
        this.walletBalance = walletBalance;
    }

    public Integer getTrustScore() {
        return trustScore;
    }

    public void setTrustScore(Integer trustScore) {
        this.trustScore = trustScore;
    }

    public String getKycStatus() {
        return kycStatus;
    }

    public void setKycStatus(String kycStatus) {
        this.kycStatus = kycStatus;
    }

    public LocalDate getDob() {
        return dob;
    }

    public void setDob(LocalDate dob) {
        this.dob = dob;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getProfilePhotoUrl() {
        return profilePhotoUrl;
    }

    public void setProfilePhotoUrl(String profilePhotoUrl) {
        this.profilePhotoUrl = profilePhotoUrl;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPincode() {
        return pincode;
    }

    public void setPincode(String pincode) {
        this.pincode = pincode;
    }

    public String getIdType() {
        return idType;
    }

    public void setIdType(String idType) {
        this.idType = idType;
    }

    public String getIdCardNumber() {
        return idCardNumber;
    }

    public void setIdCardNumber(String idCardNumber) {
        this.idCardNumber = idCardNumber;
    }

    public String getIdCardFrontUrl() {
        return idCardFrontUrl;
    }

    public void setIdCardFrontUrl(String idCardFrontUrl) {
        this.idCardFrontUrl = idCardFrontUrl;
    }

    public String getIdCardBackUrl() {
        return idCardBackUrl;
    }

    public void setIdCardBackUrl(String idCardBackUrl) {
        this.idCardBackUrl = idCardBackUrl;
    }

    public String getSelfieUrl() {
        return selfieUrl;
    }

    public void setSelfieUrl(String selfieUrl) {
        this.selfieUrl = selfieUrl;
    }

    public Double getCurrentLat() {
        return currentLat;
    }

    public void setCurrentLat(Double currentLat) {
        this.currentLat = currentLat;
    }

    public Double getCurrentLng() {
        return currentLng;
    }

    public void setCurrentLng(Double currentLng) {
        this.currentLng = currentLng;
    }

    public java.time.OffsetDateTime getLastLocationUpdate() {
        return lastLocationUpdate;
    }

    public void setLastLocationUpdate(java.time.OffsetDateTime lastLocationUpdate) {
        this.lastLocationUpdate = lastLocationUpdate;
    }

    public String getBankAccountName() {
        return bankAccountName;
    }

    public void setBankAccountName(String bankAccountName) {
        this.bankAccountName = bankAccountName;
    }

    public String getBankAccountNumber() {
        return bankAccountNumber;
    }

    public void setBankAccountNumber(String bankAccountNumber) {
        this.bankAccountNumber = bankAccountNumber;
    }

    public String getBankIfsc() {
        return bankIfsc;
    }

    public void setBankIfsc(String bankIfsc) {
        this.bankIfsc = bankIfsc;
    }

    public String getUpiId() {
        return upiId;
    }

    public void setUpiId(String upiId) {
        this.upiId = upiId;
    }

    public String getGigTypes() {
        return gigTypes;
    }

    public void setGigTypes(String gigTypes) {
        this.gigTypes = gigTypes;
    }

    public Double getWorkRadius() {
        return workRadius;
    }

    public void setWorkRadius(Double workRadius) {
        this.workRadius = workRadius;
    }

    public String getAvailableTimeSlots() {
        return availableTimeSlots;
    }

    public void setAvailableTimeSlots(String availableTimeSlots) {
        this.availableTimeSlots = availableTimeSlots;
    }

    public Boolean getWillingToTravel() {
        return willingToTravel;
    }

    public void setWillingToTravel(Boolean willingToTravel) {
        this.willingToTravel = willingToTravel;
    }

    public String getEmployerType() {
        return employerType;
    }

    public void setEmployerType(String employerType) {
        this.employerType = employerType;
    }

    public String getBusinessName() {
        return businessName;
    }

    public void setBusinessName(String businessName) {
        this.businessName = businessName;
    }

    public String getNatureOfWork() {
        return natureOfWork;
    }

    public void setNatureOfWork(String natureOfWork) {
        this.natureOfWork = natureOfWork;
    }

    public String getBusinessAddress() {
        return businessAddress;
    }

    public void setBusinessAddress(String businessAddress) {
        this.businessAddress = businessAddress;
    }

    public String getBillingName() {
        return billingName;
    }

    public void setBillingName(String billingName) {
        this.billingName = billingName;
    }

    public String getGstNumber() {
        return gstNumber;
    }

    public void setGstNumber(String gstNumber) {
        this.gstNumber = gstNumber;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getInvoiceAddress() {
        return invoiceAddress;
    }

    public void setInvoiceAddress(String invoiceAddress) {
        this.invoiceAddress = invoiceAddress;
    }

    public Boolean getIsAgreedToTerms() {
        return isAgreedToTerms;
    }

    public void setIsAgreedToTerms(Boolean isAgreedToTerms) {
        this.isAgreedToTerms = isAgreedToTerms;
    }
}
