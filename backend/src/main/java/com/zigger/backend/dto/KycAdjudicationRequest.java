package com.zigger.backend.dto;

import lombok.Data;

@Data
public class KycAdjudicationRequest {
    private String status; // "approved" or "rejected"
    private String rejectionReason;
}
