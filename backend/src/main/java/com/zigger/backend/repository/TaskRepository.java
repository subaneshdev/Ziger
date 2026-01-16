package com.zigger.backend.repository;

import com.zigger.backend.model.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TaskRepository extends JpaRepository<Task, UUID> {
    List<Task> findByStatus(String status);
    List<Task> findByCreatedBy_Id(UUID creatorId);
    List<Task> findByAssignedTo_Id(UUID workerId);


    @org.springframework.data.jpa.repository.Query(value = "SELECT * FROM tasks t WHERE t.status = 'open' AND " +
            "(6371 * acos(cos(radians(:lat)) * cos(radians(t.geo_lat)) * cos(radians(t.geo_lng) - radians(:lng)) + " +
            "sin(radians(:lat)) * sin(radians(t.geo_lat)))) < :radius", nativeQuery = true)
    List<Task> findNearbyTasks(@org.springframework.data.repository.query.Param("lat") double lat,
                               @org.springframework.data.repository.query.Param("lng") double lng,
                               @org.springframework.data.repository.query.Param("radius") double radius);
}
