package com.zigger.backend.dto;

import lombok.Data;

@Data
public class RefineRequest {
    private String text;
    private String context; // e.g., "gig_description"
}
