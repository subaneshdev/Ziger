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
@Table(name = "task_applications")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TaskApplication {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "task_id", nullable = false)
    private Task task;

    @ManyToOne
    @JoinColumn(name = "worker_id", nullable = false)
    private Profile worker;

    @Column(name = "bid_amount")
    private BigDecimal bidAmount;

    @Column(name = "pitch_message", columnDefinition = "text")
    private String pitchMessage;

    private String status = "pending";

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;
}
