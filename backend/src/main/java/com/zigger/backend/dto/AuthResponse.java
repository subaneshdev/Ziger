package com.zigger.backend.dto;

import com.zigger.backend.model.Profile;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private Profile profile;
}
