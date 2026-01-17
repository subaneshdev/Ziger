package com.zigger.backend.dto;

public class RefineResponse {
    private String refinedText;

    public RefineResponse() {
    }

    public RefineResponse(String refinedText) {
        this.refinedText = refinedText;
    }

    public String getRefinedText() {
        return refinedText;
    }

    public void setRefinedText(String refinedText) {
        this.refinedText = refinedText;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String refinedText;

        public Builder refinedText(String refinedText) {
            this.refinedText = refinedText;
            return this;
        }

        public RefineResponse build() {
            return new RefineResponse(refinedText);
        }
    }
}
