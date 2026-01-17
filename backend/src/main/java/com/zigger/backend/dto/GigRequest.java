package com.zigger.backend.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

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

    public GigRequest() {
    }

    public GigRequest(String title, String description, String locationName, Double geoLat, Double geoLng,
            BigDecimal payout, OffsetDateTime startTime, OffsetDateTime endTime, BigDecimal estimatedHours) {
        this.title = title;
        this.description = description;
        this.locationName = locationName;
        this.geoLat = geoLat;
        this.geoLng = geoLng;
        this.payout = payout;
        this.startTime = startTime;
        this.endTime = endTime;
        this.estimatedHours = estimatedHours;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLocationName() {
        return locationName;
    }

    public void setLocationName(String locationName) {
        this.locationName = locationName;
    }

    public Double getGeoLat() {
        return geoLat;
    }

    public void setGeoLat(Double geoLat) {
        this.geoLat = geoLat;
    }

    public Double getGeoLng() {
        return geoLng;
    }

    public void setGeoLng(Double geoLng) {
        this.geoLng = geoLng;
    }

    public BigDecimal getPayout() {
        return payout;
    }

    public void setPayout(BigDecimal payout) {
        this.payout = payout;
    }

    public OffsetDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(OffsetDateTime startTime) {
        this.startTime = startTime;
    }

    public OffsetDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(OffsetDateTime endTime) {
        this.endTime = endTime;
    }

    public BigDecimal getEstimatedHours() {
        return estimatedHours;
    }

    public void setEstimatedHours(BigDecimal estimatedHours) {
        this.estimatedHours = estimatedHours;
    }
}
