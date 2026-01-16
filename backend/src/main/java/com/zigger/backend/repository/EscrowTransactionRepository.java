package com.zigger.backend.repository;

import com.zigger.backend.model.EscrowTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface EscrowTransactionRepository extends JpaRepository<EscrowTransaction, UUID> {
    List<EscrowTransaction> findByTask_Id(UUID taskId);
}
