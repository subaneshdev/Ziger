package com.zigger.backend.dto;

public class KycAdjudicationRequest {
    private String status; // "approved" or "rejected"
    private String rejectionReason;

    public KycAdjudicationRequest() {
    }

    public KycAdjudicationRequest(String status, String rejectionReason) {
        this.status = status;
        this.rejectionReason = rejectionReason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }
}
