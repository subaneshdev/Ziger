package com.zigger.backend.repository;

import com.zigger.backend.model.TaskApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TaskApplicationRepository extends JpaRepository<TaskApplication, UUID> {
    List<TaskApplication> findByTask_Id(UUID taskId);

    List<TaskApplication> findByWorker_Id(UUID workerId);

    Optional<TaskApplication> findByTask_IdAndWorker_Id(UUID taskId, UUID workerId);
}
