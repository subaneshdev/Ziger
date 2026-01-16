package com.zigger.backend.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Data
@com.fasterxml.jackson.annotation.JsonIgnoreProperties(ignoreUnknown = true)
public class GigRequest {
    private String title;
    private String description;
    private String locationName;
    private Double geoLat;
    private Double geoLng;
    private BigDecimal payout;
    private OffsetDateTime startTime;
    private OffsetDateTime endTime;
    private BigDecimal estimatedHours;
    // Category specific fields can be a Map<String, Object> or JSON string in
    // future
}
