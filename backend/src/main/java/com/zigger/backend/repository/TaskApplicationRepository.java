package com.zigger.backend.repository;

import com.zigger.backend.model.TaskApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TaskApplicationRepository extends JpaRepository<TaskApplication, UUID> {
    List<TaskApplication> findByTaskId(UUID taskId);
    List<TaskApplication> findByWorkerId(UUID workerId);
    Optional<TaskApplication> findByTaskIdAndWorkerId(UUID taskId, UUID workerId);
}
