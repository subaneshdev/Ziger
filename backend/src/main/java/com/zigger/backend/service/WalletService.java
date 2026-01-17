package com.zigger.backend.service;

import com.zigger.backend.model.EscrowTransaction;
import com.zigger.backend.model.Profile;
import com.zigger.backend.model.Task;
import com.zigger.backend.model.WalletTransaction;
import com.zigger.backend.repository.EscrowTransactionRepository;
import com.zigger.backend.repository.ProfileRepository;
import com.zigger.backend.repository.TaskRepository;
import com.zigger.backend.repository.WalletTransactionRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.UUID;

import java.util.List;

@Service
public class WalletService {

    public List<WalletTransaction> getTransactions(UUID userId) {
        return walletTransactionRepository.findByProfile_IdOrderByCreatedAtDesc(userId);
    }

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private WalletTransactionRepository walletTransactionRepository;

    @Autowired
    private EscrowTransactionRepository escrowTransactionRepository;

    @Autowired
    private TaskRepository taskRepository;

    @Transactional
    public void deposit(UUID userId, BigDecimal amount) {
        Profile profile = profileRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        profile.setWalletBalance(profile.getWalletBalance().add(amount));
        profileRepository.save(profile);

        createTransaction(profile, amount, "CREDIT", "Deposit Funds", null);
    }

    @Transactional
    public void lockFundsForTask(UUID employerId, Task task) {
        Profile employer = profileRepository.findById(employerId)
                .orElseThrow(() -> new RuntimeException("Employer not found"));

        if (employer.getWalletBalance().compareTo(task.getPayout()) < 0) {
            throw new RuntimeException("Insufficient wallet balance");
        }

        // Deduct from Wallet
        employer.setWalletBalance(employer.getWalletBalance().subtract(task.getPayout()));
        profileRepository.save(employer);
        createTransaction(employer, task.getPayout(), "DEBIT", "Escrow Lock for Task: " + task.getTitle(), task.getId());

        // Create Escrow Record
        EscrowTransaction escrow = new EscrowTransaction();
        escrow.setTask(task);
        escrow.setPayer(employer);
        escrow.setAmount(task.getPayout());
        escrow.setStatus("held");
        escrowTransactionRepository.save(escrow);
    }

    @Transactional
    public void releaseFundsToWorker(Task task) {
        EscrowTransaction escrow = escrowTransactionRepository.findByTask_Id(task.getId()).stream().findFirst()
                .orElseThrow(() -> new RuntimeException("Escrow record not found"));

        if (!"held".equals(escrow.getStatus())) {
            return; // Already released or refunded
        }

        Profile worker = task.getAssignedTo();
        if (worker == null) throw new RuntimeException("No worker assigned");

        // Credit Worker
        worker.setWalletBalance(worker.getWalletBalance().add(escrow.getAmount()));
        profileRepository.save(worker);
        createTransaction(worker, escrow.getAmount(), "CREDIT", "Payout for Task: " + task.getTitle(), task.getId());

        // Update Escrow
        escrow.setStatus("released");
        escrow.setPayee(worker);
        escrowTransactionRepository.save(escrow);
    }

    @Transactional
    public void refundToEmployer(Task task) {
        EscrowTransaction escrow = escrowTransactionRepository.findByTask_Id(task.getId()).stream().findFirst()
                .orElseThrow(() -> new RuntimeException("Escrow record not found"));

        if (!"held".equals(escrow.getStatus())) {
            return; // Already released or refunded
        }

        Profile employer = escrow.getPayer();

        // Credit Employer
        employer.setWalletBalance(employer.getWalletBalance().add(escrow.getAmount()));
        profileRepository.save(employer);
        createTransaction(employer, escrow.getAmount(), "CREDIT", "Refund for Task: " + task.getTitle(), task.getId());

        // Update Escrow
        escrow.setStatus("refunded");
        escrowTransactionRepository.save(escrow);
    }

    private void createTransaction(Profile profile, BigDecimal amount, String type, String desc, UUID refId) {
        WalletTransaction txn = new WalletTransaction();
        txn.setProfile(profile);
        txn.setAmount(amount);
        txn.setType(type);
        txn.setDescription(desc);
        txn.setReferenceId(refId);
        walletTransactionRepository.save(txn);
    }
}
