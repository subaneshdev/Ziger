package com.zigger.backend.dto;

import lombok.Data;

@Data
public class OtpVerifyRequest {
    private String mobile;
    private String otp;
}
