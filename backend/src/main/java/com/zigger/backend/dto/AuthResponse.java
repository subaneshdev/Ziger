package com.zigger.backend.dto;

import com.zigger.backend.model.Profile;

public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private Profile profile;

    public AuthResponse() {
    }

    public AuthResponse(String accessToken, String refreshToken, Profile profile) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.profile = profile;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public Profile getProfile() {
        return profile;
    }

    public void setProfile(Profile profile) {
        this.profile = profile;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String accessToken;
        private String refreshToken;
        private Profile profile;

        public Builder accessToken(String accessToken) {
            this.accessToken = accessToken;
            return this;
        }

        public Builder refreshToken(String refreshToken) {
            this.refreshToken = refreshToken;
            return this;
        }

        public Builder profile(Profile profile) {
            this.profile = profile;
            return this;
        }

        public AuthResponse build() {
            return new AuthResponse(accessToken, refreshToken, profile);
        }
    }
}
