package com.zigger.backend.service;

import com.zigger.backend.model.Profile;
import com.zigger.backend.model.Task;
import com.zigger.backend.model.WalletTransaction;
import com.zigger.backend.repository.ProfileRepository;
import com.zigger.backend.repository.TaskRepository;
import com.zigger.backend.repository.WalletTransactionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminService {

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private TaskRepository taskRepository;

    @Autowired
    private WalletTransactionRepository walletTransactionRepository;

    public List<Profile> getAllUsers() {
        return profileRepository.findAll();
    }

    public List<Task> getAllGigs() {
        return taskRepository.findAll();
    }

    public List<WalletTransaction> getAllTransactions() {
        return walletTransactionRepository.findAll();
    }
    
    // Additional admin logic (stats, etc.) can go here
}
