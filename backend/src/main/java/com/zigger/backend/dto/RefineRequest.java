package com.zigger.backend.dto;

public class RefineRequest {
    private String text;
    private String context; // e.g., "gig_description"

    public RefineRequest() {
    }

    public RefineRequest(String text, String context) {
        this.text = text;
        this.context = context;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getContext() {
        return context;
    }

    public void setContext(String context) {
        this.context = context;
    }
}
