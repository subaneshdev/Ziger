package com.zigger.backend.repository;

import com.zigger.backend.model.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProfileRepository extends JpaRepository<Profile, UUID> {
    Optional<Profile> findByMobile(String mobile);
    List<Profile> findByKycStatus(String kycStatus);
}
