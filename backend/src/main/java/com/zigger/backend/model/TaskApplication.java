package com.zigger.backend.model;

import jakarta.persistence.*;

import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "task_applications")
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

    public TaskApplication() {
    }

    public TaskApplication(UUID id, Task task, Profile worker, BigDecimal bidAmount, String pitchMessage, String status,
            OffsetDateTime createdAt) {
        this.id = id;
        this.task = task;
        this.worker = worker;
        this.bidAmount = bidAmount;
        this.pitchMessage = pitchMessage;
        this.status = status;
        this.createdAt = createdAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Task getTask() {
        return task;
    }

    public void setTask(Task task) {
        this.task = task;
    }

    public Profile getWorker() {
        return worker;
    }

    public void setWorker(Profile worker) {
        this.worker = worker;
    }

    public BigDecimal getBidAmount() {
        return bidAmount;
    }

    public void setBidAmount(BigDecimal bidAmount) {
        this.bidAmount = bidAmount;
    }

    public String getPitchMessage() {
        return pitchMessage;
    }

    public void setPitchMessage(String pitchMessage) {
        this.pitchMessage = pitchMessage;
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
}
