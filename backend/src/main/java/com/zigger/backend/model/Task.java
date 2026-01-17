package com.zigger.backend.model;

import jakarta.persistence.*;

import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "tasks")
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "text")
    private String description;

    @Column(name = "location_name", nullable = false)
    private String locationName;

    @Column(name = "geo_lat", nullable = false)
    private Double geoLat;

    @Column(name = "geo_lng", nullable = false)
    private Double geoLng;

    @Column(nullable = false)
    private BigDecimal payout;

    private String currency = "INR";

    @Column(name = "start_time")
    private OffsetDateTime startTime;

    @Column(name = "end_time")
    private OffsetDateTime endTime;

    @Column(name = "estimated_hours")
    private BigDecimal estimatedHours;

    @Column(name = "actual_start_time")
    private OffsetDateTime actualStartTime;

    @Column(name = "actual_end_time")
    private OffsetDateTime actualEndTime;

    @Column(name = "proof_photo_url")
    private String proofPhotoUrl;

    @Column(name = "live_lat")
    private Double liveLat;

    @Column(name = "live_lng")
    private Double liveLng;

    @Column(name = "last_updated")
    private OffsetDateTime lastUpdated;

    @ElementCollection
    @CollectionTable(name = "task_progress_photos", joinColumns = @JoinColumn(name = "task_id"))
    @Column(name = "photo_url")
    private List<String> inProgressPhotos = new ArrayList<>();

    @ManyToOne
    @JoinColumn(name = "created_by", nullable = false)
    private Profile createdBy;

    @ManyToOne
    @JoinColumn(name = "assigned_to")
    private Profile assignedTo;

    private String status = "open";

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @org.hibernate.annotations.Formula("(SELECT count(*) FROM task_applications ta WHERE ta.task_id = id)")
    private Integer applicationCount;

    public Task() {
    }

    public Task(UUID id, String title, String description, String locationName, Double geoLat, Double geoLng,
            BigDecimal payout, String currency, OffsetDateTime startTime, OffsetDateTime endTime,
            BigDecimal estimatedHours, OffsetDateTime actualStartTime, OffsetDateTime actualEndTime,
            String proofPhotoUrl, Double liveLat, Double liveLng, OffsetDateTime lastUpdated,
            List<String> inProgressPhotos, Profile createdBy, Profile assignedTo, String status,
            OffsetDateTime createdAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.locationName = locationName;
        this.geoLat = geoLat;
        this.geoLng = geoLng;
        this.payout = payout;
        this.currency = currency;
        this.startTime = startTime;
        this.endTime = endTime;
        this.estimatedHours = estimatedHours;
        this.actualStartTime = actualStartTime;
        this.actualEndTime = actualEndTime;
        this.proofPhotoUrl = proofPhotoUrl;
        this.liveLat = liveLat;
        this.liveLng = liveLng;
        this.lastUpdated = lastUpdated;
        this.inProgressPhotos = inProgressPhotos;
        this.createdBy = createdBy;
        this.assignedTo = assignedTo;
        this.status = status;
        this.createdAt = createdAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
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

    public OffsetDateTime getActualStartTime() {
        return actualStartTime;
    }

    public void setActualStartTime(OffsetDateTime actualStartTime) {
        this.actualStartTime = actualStartTime;
    }

    public OffsetDateTime getActualEndTime() {
        return actualEndTime;
    }

    public void setActualEndTime(OffsetDateTime actualEndTime) {
        this.actualEndTime = actualEndTime;
    }

    public String getProofPhotoUrl() {
        return proofPhotoUrl;
    }

    public void setProofPhotoUrl(String proofPhotoUrl) {
        this.proofPhotoUrl = proofPhotoUrl;
    }

    public Double getLiveLat() {
        return liveLat;
    }

    public void setLiveLat(Double liveLat) {
        this.liveLat = liveLat;
    }

    public Double getLiveLng() {
        return liveLng;
    }

    public void setLiveLng(Double liveLng) {
        this.liveLng = liveLng;
    }

    public OffsetDateTime getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(OffsetDateTime lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public List<String> getInProgressPhotos() {
        return inProgressPhotos;
    }

    public void setInProgressPhotos(List<String> inProgressPhotos) {
        this.inProgressPhotos = inProgressPhotos;
    }

    public Profile getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Profile createdBy) {
        this.createdBy = createdBy;
    }

    public Profile getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Profile assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Integer getApplicationCount() {
        return applicationCount;
    }

    public void setApplicationCount(Integer applicationCount) {
        this.applicationCount = applicationCount;
    }
}
