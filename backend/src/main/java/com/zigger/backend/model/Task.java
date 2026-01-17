package com.zigger.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "tasks")
@Data
@NoArgsConstructor
@AllArgsConstructor
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
    private String proofPhotoUrl; // Can be used for intermediate updates

    @Column(name = "check_in_photo_url")
    private String checkInPhotoUrl;

    @Column(name = "check_out_photo_url")
    private String checkOutPhotoUrl;

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
}
